defmodule Rabbit.Runtime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Rabbit.Registry},
      Rabbit.Vault,
      Rabbit.Repo,
      {Finch, name: Rabbit.Finch},
      {Rabbit.Runtime.Supervisor, name: Rabbit.MonitorSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rabbit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
