defmodule Rabbit.Runtime.Monitor do
  @moduledoc """
  Monitors all RabbitMQ Server instances.

  ## Overview

  1. Monitor is started by a Supervisor on application start.
  2. Implemented using `GenServer`.
  3. Utilizes an ETS cache for fast lookups.
  4. Dynamically starts server instances using a `DynamicSupervisor`.
  """

  alias Ecto.Changeset
  alias Rabbit.Impl.Client.Config
  alias Rabbit.Impl.Clients
  alias Rabbit.Runtime.{Monitor, Server}

  require Logger

  # ------------------------------------------------------------------------

  @default_interval 5_000
  @ets_table Rabbit.ETSCache
  @name Rabbit.Monitor

  # ------------------------------------------------------------------------

  defstruct [:configs, :refreshed_at, default_interval: @default_interval]

  @type t :: %Monitor{
          configs: [Config.t()],
          refreshed_at: DateTime.t(),
          default_interval: non_neg_integer()
        }

  # ------------------------------------------------------------------------
  # GenServer
  # ========================================================================

  use GenServer

  # ------------------------------------------------------------------------

  @doc """
  Starts the monitor process.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: @name)
  end

  # ------------------------------------------------------------------------

  @type state_response :: %{refreshed_at: DateTime.t(), rabbit_servers: [Server.t()]}
  @doc """
  Retrieves the current state of all monitored RabbitMQ servers.
  """
  @spec get_state() :: state_response()
  def get_state() do
    GenServer.call(@name, :get_state)
  end

  # ------------------------------------------------------------------------

  @doc """
  Retrieves the state of a specific RabbitMQ server by its ID.
  """
  @spec get_client_state(non_neg_integer()) :: Server.t() | {:error, String.t()}
  def get_client_state(server_id) do
    case :ets.lookup(@ets_table, server_id) do
      [{^server_id, state}] -> state
      [] -> {:error, "Server ID: #{server_id} not found"}
    end
  end

  # ------------------------------------------------------------------------

  @doc """
  Adds a new RabbitMQ client configuration.
  """
  @spec add_client(map()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def add_client(params) do
    GenServer.call(@name, {:add_client, params})
  end

  # ------------------------------------------------------------------------

  @doc """
  Updates an existing RabbitMQ client configuration.
  """
  @spec update_client(non_neg_integer(), map()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def update_client(server_id, attr) do
    with [{^server_id, _state}] <- :ets.lookup(@ets_table, server_id),
         %Config{} = config <- Clients.get_config(server_id) do
      GenServer.call(@name, {:update_config, server_id, config, attr})
    else
      _ -> {:error, "server_#{server_id} not found."}
    end
  end

  # ------------------------------------------------------------------------

  @doc """
  Deletes an existing RabbitMQ client configuration.
  """
  @spec delete_client(non_neg_integer()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def delete_client(server_id) do
    with [{^server_id, _state}] <- :ets.lookup(@ets_table, server_id),
         %Config{} = config <- Clients.get_config(server_id) do
      GenServer.call(@name, {:delete_config, config})
    else
      _ -> {:error, "server_#{server_id} not found."}
    end
  end

  # ------------------------------------------------------------------------

  @doc """
  Triggers the refresh of all RabbitMQ server states.
  """
  @spec refresh() :: :ok
  def refresh() do
    send(self(), :refresh)
  end

  # ------------------------------------------------------------------------
  # Callbacks
  # ========================================================================

  @impl true
  def init(:ok) do
    # ETS Cache
    :ets.new(@ets_table, [:public, :named_table, read_concurrency: true, write_concurrency: true])

    state = %Monitor{}

    # Schedule refresh
    :timer.send_interval(state.default_interval, :refresh)

    # Defer starting servers until after init/1 returns
    {:ok, state, {:continue, :start_servers}}
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_continue(:start_servers, %Monitor{} = state) do
    configs = Clients.list_configs()

    # Spawn processes to start individual servers to avoid
    # performance bottlenecks.
    for config <- configs do
      spawn(fn -> start_server(config) end)
    end

    {:noreply, %{state | configs: configs}}
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_call(:get_state, _from, %Monitor{configs: configs} = state) do
    rabbit_servers =
      for config <- configs do
        case :ets.lookup(@ets_table, config.id) do
          [{_server_id, server_state}] -> server_state
          _ -> nil
        end
      end

    response = %{
      refreshed_at: state.refreshed_at,
      rabbit_servers: Enum.reject(rabbit_servers, &is_nil/1)
    }

    {:reply, response, state}
  end

  @impl true
  def handle_call({:add_client, params}, _from, %Monitor{configs: configs} = state) do
    with {:ok, config} <- Clients.create_config(params),
         {:ok, _pid} <- start_server(config) do
      :ets.insert(@ets_table, {config.id, Server.get_state(config.id)})
      {:reply, {:ok, config}, %{state | configs: [config | configs]}}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(
        {:update_config, server_id, %Config{} = config, attr},
        _from,
        %Monitor{configs: configs} = state
      ) do
    new_configs = Enum.reject(configs, fn cfg -> config.id == cfg.id end)

    case Clients.update_config(config, attr) do
      {:ok, new_config} ->
        Server.update_config(server_id, new_config)
        :ets.insert(@ets_table, {new_config.id, Server.get_state(new_config.id)})
        {:reply, {:ok, new_config}, %{state | configs: [new_config | new_configs]}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:delete_config, %Config{} = config}, _from, %Monitor{configs: configs} = state) do
    new_configs = Enum.reject(configs, fn cfg -> config.id == cfg.id end)

    case Clients.delete_config(config) do
      {:ok, deleted_config} ->
        Server.stop(config.id, :normal)
        :ets.delete(@ets_table, config.id)
        {:reply, {:ok, deleted_config}, %{state | configs: new_configs}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_info(:refresh, %Monitor{configs: configs} = state) do
    Enum.each(configs, fn config ->
      spawn(fn ->
        # TODO: remove inspect after demo
        state = Server.get_state(config.id)
        IO.inspect(state, pretty: true)
        :ets.insert(@ets_table, {config.id, state})
      end)
    end)

    {:noreply, %{state | refreshed_at: DateTime.utc_now()}}
  end

  # ------------------------------------------------------------------------
  # Helpers
  # ========================================================================

  defp start_server(%Config{} = config) do
    case DynamicSupervisor.start_child(Rabbit.ServerSupervisor, {Server, config}) do
      {:ok, pid} ->
        Logger.info("Successfully started: rabbit_server_#{config.id}")
        {:ok, pid}

      {:error, reason} ->
        Logger.error(
          "Error starting server_id: '#{config.id}' with reason: #{inspect(reason, pretty: true)}"
        )

        {:error, reason}
    end
  end
end
