defmodule Rabbit do
  @moduledoc """
  Documentation for `Rabbit`.
  """
  alias Rabbit.Impl.Client.Config
  alias Rabbit.Runtime.{Monitor, Server}

  @spec get_state() :: %{rabbit_servers: [Server.t()], refreshed_at: DateTime.t()}
  defdelegate get_state, to: Monitor

  @spec add_client(map()) :: {:error, Ecto.Changeset.t()} | {:ok, Config.t()}
  defdelegate add_client(params), to: Monitor

  @spec update_client(non_neg_integer(), map()) ::
          {:error, Ecto.Changeset.t()} | {:ok, Config.t()}
  defdelegate update_client(server_id, attr), to: Monitor

  @spec delete_client(non_neg_integer()) :: {:error, Ecto.Changeset.t()} | {:ok, Config.t()}
  defdelegate delete_client(server_id), to: Monitor

  @spec get_client_state(non_neg_integer()) :: {:error, String.t()} | Server.t()
  defdelegate get_client_state(server_id), to: Monitor

  @spec refresh() :: :ok
  defdelegate refresh, to: Monitor

  # TODO: Functions -> purge_queue, multiple instances and broadcast
end
