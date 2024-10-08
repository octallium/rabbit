defmodule Rabbit.Impl.Queue do
  @moduledoc """
  RabbitMQ queue representation.

  ## Example:

      %Rabbit.Impl.Queue{
        name: "random_queue",
        vhost: "/",
        messages_persistent: 0,
        messages_unacknowledged_details: %{rate: 0.0},
        message_stats: %{publish: 21918, publish_details: %{rate: 0.0}},
        memory: 4120080,
        storage_version: 1,
        message_bytes_ram: 18,
        consumers: 0,
        messages_paged_out: 21917,
        type: "classic",
        message_bytes: 400547,
        node: "rabbit@a35322b409c2",
        auto_delete: false,
        messages: 21918,
        message_bytes_unacknowledged: 0,
        messages_unacknowledged: 0,
        consumer_utilisation: 0,
        messages_unacknowledged_ram: 0,
        message_bytes_paged_out: 400529,
        messages_ready_details: %{rate: 0.0},
        messages_ready: 21918,
        durable: false,
        reductions_details: %{rate: 0.0},
        consumer_capacity: 0,
        message_bytes_ready: 400547,
        messages_ready_ram: 1,
        message_bytes_persistent: 0,
        messages_details: %{rate: 0.0},
        exclusive: false,
        arguments: %{},
        reductions: 11455236,
        effective_policy_definition: %{},
        state: "running",
        messages_ram: 1
      }
  """
  defstruct [
    :name,
    :vhost,
    :messages_persistent,
    :messages_unacknowledged_details,
    :message_stats,
    :memory,
    :storage_version,
    :message_bytes_ram,
    :consumers,
    :messages_paged_out,
    :type,
    :message_bytes,
    :node,
    :auto_delete,
    :messages,
    :message_bytes_unacknowledged,
    :messages_unacknowledged,
    :consumer_utilisation,
    :messages_unacknowledged_ram,
    :message_bytes_paged_out,
    :messages_ready_details,
    :messages_ready,
    :durable,
    :reductions_details,
    :consumer_capacity,
    :message_bytes_ready,
    :messages_ready_ram,
    :message_bytes_persistent,
    :messages_details,
    :exclusive,
    :arguments,
    :reductions,
    :effective_policy_definition,
    :state,
    :messages_ram
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          vhost: String.t(),
          messages_persistent: non_neg_integer(),
          messages_unacknowledged_details: map(),
          message_stats: map(),
          memory: non_neg_integer(),
          storage_version: non_neg_integer(),
          message_bytes_ram: non_neg_integer(),
          consumers: non_neg_integer(),
          messages_paged_out: non_neg_integer(),
          type: String.t(),
          message_bytes: non_neg_integer(),
          node: String.t(),
          auto_delete: boolean(),
          messages: non_neg_integer(),
          message_bytes_unacknowledged: non_neg_integer(),
          messages_unacknowledged: non_neg_integer(),
          consumer_utilisation: non_neg_integer(),
          messages_unacknowledged_ram: non_neg_integer(),
          message_bytes_paged_out: non_neg_integer(),
          messages_ready_details: map(),
          messages_ready: non_neg_integer(),
          durable: boolean(),
          reductions_details: map(),
          consumer_capacity: non_neg_integer(),
          message_bytes_ready: non_neg_integer(),
          messages_ready_ram: non_neg_integer(),
          message_bytes_persistent: non_neg_integer(),
          messages_details: map(),
          exclusive: boolean(),
          arguments: map(),
          reductions: non_neg_integer(),
          effective_policy_definition: map(),
          state: String.t(),
          messages_ram: non_neg_integer()
        }
end
