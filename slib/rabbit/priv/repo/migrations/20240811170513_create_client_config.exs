defmodule Rabbit.Repo.Migrations.CreateClientConfig do
  use Ecto.Migration

  def change do
    create table(:client_configs) do
      add(:name, :string, null: false)
      add(:env, :string, null: false)
      add(:mgmt_uri, :map, null: false)
      add(:mgmt_auth_hash, :binary, null: false)

      timestamps()
    end

    create(unique_index(:client_configs, [:name, :env]))
  end
end
