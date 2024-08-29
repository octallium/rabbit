defmodule Rabbit.Impl.Clients do
  @moduledoc """
  Functions for managing RabbitMQ client configurations.
  """

  alias Rabbit.Repo
  alias Rabbit.Impl.Client.Config

  @doc """
  Lists all client configs
  """
  @spec list_configs() :: [Config.t()]
  def list_configs do
    Repo.all(Config)
  end

  @doc """
  Retrieves a client config by its ID.
  """
  @spec get_config(non_neg_integer()) :: Config.t() | nil
  def get_config(id), do: Repo.get(Config, id)

  @doc """
  Creates a new client config.

  ## Examples

      iex> create_config(%{name: "ABC", env: "Dev", mgmt_uri: "http://user:password@localhost:15672"})
      {:ok, %Config{}}

      iex> create_config(%{name: nil})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_config(map()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def create_config(attrs \\ %{}) do
    %Config{}
    |> Config.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing client config.

  ## Examples

      iex> update_config(config, %{env: "Stage"})
      {:ok, %Config{}}

      iex> update_config(config, %{host: nil})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_config(Config.t(), map()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a client config.

  ## Examples

      iex> delete_config(config)
      {:ok, %Config{}}

      iex> delete_config(invalid_config)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_config(Config.t()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def delete_config(%Config{} = config) do
    Repo.delete(config)
  end

  @doc """
  Returns a changeset for tracking client config changes.

  ## Examples

      iex> change_config(config)
      %Ecto.Changeset{data: %Config{}}
  """
  @spec change_config(Config.t()) :: Ecto.Changeset.t()
  def change_config(%Config{} = config) do
    Config.changeset(config, %{})
  end
end
