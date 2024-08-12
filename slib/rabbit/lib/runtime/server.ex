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

  use GenServer

  # ------------------------------------------------------------------------
  # Client
  # ========================================================================

  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: via_tuple(config.id))
  end

  # ------------------------------------------------------------------------

  defp via_tuple(id) do
    name = "rabbit_server_#{id}"
    {:via, Registry, {Rabbit.Registry, name}}
  end

  # ------------------------------------------------------------------------

  def get_state(server_id) do
    GenServer.call(via_tuple(server_id), :get_state)
  end

  # ------------------------------------------------------------------------

  def refresh(server_id) do
    GenServer.call(via_tuple(server_id), :refresh_server)
  end

  # ------------------------------------------------------------------------

  def purge_queue(server_id, queue_name) do
    GenServer.call(via_tuple(server_id), {:purge_queue, queue_name})
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
    {:reply, state, state}
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
  def handle_call(:refresh_server, _from, %Server{} = state) do
    new_state = refresh_server(state)
    {:reply, new_state, new_state}
  end

  # ------------------------------------------------------------------------

  @impl true
  def handle_continue(:continue_init, state) do
    new_state = refresh_server(state)
    {:noreply, new_state}
  end

  # ------------------------------------------------------------------------

  defp refresh_server(%Server{} = state) do
    with {:ok, queues} <- Manager.get_queues(state.config),
         {:ok, %{"status" => "ok"}} <- Manager.check_health(state.config) do
      %{state | queues: queues, health: "ok", state: :ready}
    else
      {:error, msg} ->
        Logger.error("Error: #{inspect(msg)}")
        %{state | state: {:error, msg}}
    end
  end
end
