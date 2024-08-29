defmodule Rabbit.Types.EctoURI do
  @moduledoc """
  Custom type for URI.
  """
  use Ecto.Type

  # ------------------------------------------------------------

  @spec type() :: :map
  def type, do: :map

  # ------------------------------------------------------------

  @spec cast(any()) :: :error | {:ok, URI.t()}
  @doc """
  Cast strings into URI struct to be used at runtime.
  """
  def cast(uri) when is_binary(uri) do
    {:ok, URI.parse(uri)}
  end

  def cast(%URI{} = uri), do: {:ok, uri}

  def cast(_), do: :error

  # ------------------------------------------------------------

  @spec load(map()) :: {:ok, URI.t()}
  @doc """
  Load data from database if it's a map and put data back into URI
  struct to be loaded back into `schema`.
  """
  def load(data) when is_map(data) do
    data =
      for {key, value} <- data do
        {String.to_existing_atom(key), value}
      end

    {:ok, struct!(URI, data)}
  end

  # ------------------------------------------------------------

  @doc """
  When dumping data to database make sure to have a URI struct.
  """
  def dump(%URI{} = uri) do
    {:ok, Map.from_struct(uri)}
  end

  def dump(_), do: :error
end
