defmodule Rabbit.CreateQueues do
  use AMQP

  @queue_prefix "random_queue_"
  @message_range 1000..10000
  @error_queues 3
  @total_queues 10

  def run do
    {:ok, conn} = Connection.open()
    {:ok, channel} = Channel.open(conn)

    # Create random queues and insert messages
    create_queues(channel)

    # Close the channel and connection
    Channel.close(channel)
    Connection.close(conn)
  end

  defp create_queues(channel) do
    Enum.each(1..@total_queues, fn index ->
      queue_name =
        if index <= @error_queues do
          "#{@queue_prefix}#{index}_error"
        else
          "#{@queue_prefix}#{index}"
        end

      create_queue(channel, queue_name)
    end)
  end

  defp create_queue(channel, queue_name) do
    Queue.declare(channel, queue_name, durable: true)
    IO.puts("Created queue: #{queue_name}")

    # Insert a random number of messages
    messages_count = Enum.random(@message_range)
    insert_messages(channel, queue_name, messages_count)
  end

  defp insert_messages(channel, queue_name, count) do
    Enum.each(1..count, fn _ ->
      message = generate_random_message()
      Basic.publish(channel, "", queue_name, message)
    end)

    IO.puts("Inserted #{count} messages into #{queue_name}")
  end

  defp generate_random_message do
    "Message #{:rand.uniform(100_000)}"
  end
end

# Run the script
Rabbit.CreateQueues.run()
