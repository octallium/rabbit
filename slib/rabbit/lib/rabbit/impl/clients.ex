defmodule Rabbit.Impl.Clients do
  alias Rabbit.Repo
  alias Rabbit.Impl.Client.Config

  def list_configs do
    Repo.all(Config)
  end

  # def get_config!(id), do: Repo.get!(Config, id)

  def get_config(id), do: Repo.get(Config, id)

  def create_config(attrs \\ %{}) do
    %Config{}
    |> Config.changeset(attrs)
    |> Repo.insert()
  end

  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  def delete_config(%Config{} = config) do
    Repo.delete(config)
  end

  def change_config(%Config{} = config) do
    Config.changeset(config, %{})
  end
end
