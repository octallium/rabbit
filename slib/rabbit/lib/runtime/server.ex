defmodule Rabbit.Runtime.Server do
  @moduledoc """
  Server instance for RabbitMQ.

  Implements using GenServer, dynamically started by DynamicSupervisor in `Monitor`
  """
  alias Rabbit.Impl.{Manager, Queue}
  alias Rabbit.Impl.Client.Config
  alias Rabbit.Runtime.Server

  require Logger

  # ------------------------------------------------------------------------

  defstruct [:config, :health, :state, :queues]

  @type server_state :: :initializing | :ready | {:error, String.t()}
  @type t :: %Server{
          config: Config.t(),
          state: server_state(),
          health: String.t(),
          queues: [Queue.t()]
        }

  # ------------------------------------------------------------------------
  # GenServer
  # ========================================================================

  use GenServer, restart: :temporary

  # ------------------------------------------------------------------------
  # Client
  # ========================================================================

  @spec start_link(Config.t()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: via_tuple(config.id))
  end

  # ------------------------------------------------------------------------

  def update_config(server_id, %Config{} = config) do
    GenServer.call(via_tuple(server_id), {:update_config, config})
  end

  # ------------------------------------------------------------------------

  @spec get_state(non_neg_integer()) :: Server.t()
  def get_state(server_id) do
    GenServer.call(via_tuple(server_id), :get_state)
  end

  # ------------------------------------------------------------------------

  @spec refresh(non_neg_integer()) :: Server.t()
  def refresh(server_id) do
    GenServer.call(via_tuple(server_id), :refresh)
  end

  # ------------------------------------------------------------------------

  @spec purge_queue(non_neg_integer(), String.t()) :: :ok | {:error, String.t()}
  def purge_queue(server_id, queue_name) do
    GenServer.call(via_tuple(server_id), {:purge_queue, queue_name})
  end

  # ------------------------------------------------------------------------

  def stop(server_id, reason) do
    GenServer.stop(via_tuple(server_id), reason)
  end

  # ------------------------------------------------------------------------
  # Callbacks
  # ========================================================================

  @impl true
  def init(config) do
    state = %Server{state: :initializing, config: config, health: "unknown"}
    {:ok, state, {:continue, :continue_init}}
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_call(:get_state, _from, state) do
    new_state = refresh_server(state)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:purge_queue, queue_name}, _from, %Server{} = state) do
    case Manager.purge_queue(state.config, queue_name) do
      :ok ->
        {:reply, :ok, state}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  @impl true
  def handle_call(:refresh, _from, %Server{} = state) do
    new_state = refresh_server(state)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:update_config, new_config}, _from, state) do
    new_state = %{state | config: new_config}
    {:reply, new_config, new_state}
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_continue(:continue_init, state) do
    new_state = refresh_server(state)
    {:noreply, new_state}
  end

  # ------------------------------------------------------------------------

  @impl true
  def terminate(reason, state) do
    Logger.info(
      "rabbit_server_#{state.config.id} is shutting down with reason: #{inspect(reason)}"
    )

    {:noreply, state}
  end

  # ------------------------------------------------------------------------
  # Helpers
  # ========================================================================

  defp via_tuple(id) do
    name = "rabbit_server_#{id}"
    {:via, Registry, {Rabbit.Registry, name}}
  end

  # ------------------------------------------------------------------------

  defp refresh_server(%Server{} = state) do
    with {:ok, queues} <- Manager.get_queues(state.config),
         {:ok, %{"status" => "ok"}} <- Manager.check_health(state.config) do
      formatter_queues =
        queues
        |> Enum.map(fn queue ->
          Map.new(queue, fn {key, val} -> {String.to_atom(key), val} end)
        end)
        |> Enum.map(fn queue -> struct(Rabbit.Impl.Queue, queue) end)

      %{state | queues: formatter_queues, health: "ok", state: :ready}
    else
      {:error, msg} ->
        Logger.error("Error: #{inspect(msg)}")
        %{state | state: {:error, msg}, health: "Unknown"}
    end
  end
end
