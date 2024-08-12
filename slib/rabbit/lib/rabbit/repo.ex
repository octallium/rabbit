defmodule Rabbit.Repo do
  use Ecto.Repo,
    otp_app: :rabbit,
    adapter: Ecto.Adapters.Postgres
end
