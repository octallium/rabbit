defmodule Rabbit.Runtime.Monitor do
  @moduledoc """
  Monitor's all RabbitMQ Server instances.

  1. Monitor is started by Supervisor on application start.
  2. Implemented using GenServer.
  3. Implements an ETS cache for fast lookups.
  4. DynamicSupervisor starts `server` instances.
  """
end
