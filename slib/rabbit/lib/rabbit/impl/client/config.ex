defmodule Rabbit.Impl.Client.Config do
  @moduledoc """
  Schema for RabbitMQ Client Config.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Rabbit.Impl.Client.Config
  alias Rabbit.Types.EctoURI

  # ------------------------------------------------------------

  schema "client_configs" do
    field(:name, :string)
    field(:env, :string)
    field(:mgmt_uri, EctoURI)
    field(:mgmt_auth_hash, :binary)

    timestamps()
  end

  # ------------------------------------------------------------

  @type t :: %Config{
          name: String.t(),
          env: String.t(),
          mgmt_uri: URI.t(),
          mgmt_auth_hash: bitstring()
        }

  # ------------------------------------------------------------

  @doc false
  def changeset(client_config, params \\ %{}) do
    client_config
    |> cast(params, [:name, :env, :mgmt_uri])
    |> validate_required([:name, :env, :mgmt_uri])
    |> unique_constraint([:name, :env])
    |> put_mgmt_auth_hash()
    |> put_cleaned_mgmt_uri()
  end

  # ------------------------------------------------------------

  defp put_mgmt_auth_hash(%{valid?: true} = changeset) do
    case get_change(changeset, :mgmt_uri) do
      %URI{userinfo: userinfo} ->
        add_hash(changeset, :mgmt_auth_hash, userinfo)

      nil ->
        changeset
    end
  end

  defp add_hash(changeset, key, to_hash) do
    case Rabbit.Vault.encrypt(to_hash) do
      {:ok, hash} -> put_change(changeset, key, hash)
      {:error, reason} -> add_error(changeset, key, reason)
    end
  end

  defp put_cleaned_mgmt_uri(changeset) do
    case get_change(changeset, :mgmt_uri) do
      nil ->
        changeset

      %{} = mgmt_uri ->
        # Remove user credentials from URI
        changeset
        |> put_change(:mgmt_uri, %{mgmt_uri | userinfo: "", authority: "", path: ""})
    end
  end
end
