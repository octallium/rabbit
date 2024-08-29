defmodule Rabbit.Runtime.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Rabbit.ServerSupervisor, strategy: :one_for_one},
      Rabbit.Runtime.Monitor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
