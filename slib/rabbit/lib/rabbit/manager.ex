defmodule Rabbit.Impl.Manager do
  @moduledoc """
  Function to interact with RabbitMQ using Management API
  """
  alias Rabbit.Impl.Client.Config

  # ------------------------------------------------------------------------

  @doc """
  Get overview of RabbitMQ instance.
  """
  @spec get_overview(Config.t()) :: {:error, String.t()} | {:ok, map()}
  def get_overview(%Config{} = config) do
    url = "#{get_url(config)}/api/overview"

    :get
    |> Finch.build(url, get_headers(config))
    |> Finch.request(Rabbit.Finch)
    |> handle_response()
  end

  # ------------------------------------------------------------------------

  @doc """
  List all of the queues.
  """
  @spec get_queues(Config.t()) :: {:error, String.t()} | {:ok, [map()]}
  def get_queues(%Config{} = config) do
    url = "#{get_url(config)}/api/queues"

    send_request(:get, url, get_headers(config))
  end

  # ------------------------------------------------------------------------

  @doc """
  List all of the `error` queues.
  """
  @spec get_all_error_queues(Config.t()) :: {:error, String.t()} | {:ok, [map()]}
  def get_all_error_queues(%Config{} = config) do
    url = "#{get_url(config)}/api/queues"

    case send_request(:get, url, get_headers(config)) do
      {:ok, queues} ->
        Enum.filter(queues, fn %{"name" => name} ->
          name |> String.downcase() |> String.contains?("error")
        end)

      {:error, msg} ->
        {:error, msg}
    end
  end

  # ------------------------------------------------------------------------

  @doc """
  Checks if there are no alarms in effect in the cluster.
  """
  @spec check_health(Config.t()) :: {:error, String.t()} | {:ok, map()}
  def check_health(%Config{} = config) do
    url = "#{get_url(config)}/api/health/checks/alarms"

    send_request(:get, url, get_headers(config))
  end

  # ------------------------------------------------------------------------

  @spec purge_queue(Config.t(), String.t(), String.t()) ::
          :ok | {:error, String.t()}
  @doc """
  Deletes all messages in a queue.
  """
  def purge_queue(%Config{} = config, queue_name, vhost \\ "%2F") do
    url = "#{get_url(config)}/api/queues/#{vhost}/#{URI.encode(queue_name)}/contents"

    send_request(:delete, url, get_headers(config))
  end

  # ------------------------------------------------------------------------

  defp get_url(%Config{} = config) do
    config.mgmt_uri |> URI.to_string()
  end

  # ------------------------------------------------------------------------

  defp get_headers(%Config{} = config) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Basic " <> Base.encode64(Rabbit.Vault.decrypt!(config.mgmt_auth_hash))}
    ]
  end

  # ------------------------------------------------------------------------

  defp send_request(action, url, headers) do
    action
    |> Finch.build(url, headers)
    |> Finch.request(Rabbit.Finch)
    |> handle_response()
  end

  # ------------------------------------------------------------------------

  defp handle_response({:ok, %Finch.Response{status: 204}}), do: :ok

  defp handle_response({:ok, %Finch.Response{status: status, body: body}})
       when status in 200..299 do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %Finch.Response{status: status, body: body}}) do
    {:error, "Failed with -> Status: #{status}, Body: #{body}"}
  end

  defp handle_response({:error, reason}) do
    {:error, "Request failed: #{reason}"}
  end
end
