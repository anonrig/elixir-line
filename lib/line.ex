defmodule Message do
  @derive [Poison.Encoder]
  defstruct [:n, :p, :i, :e]
end

defmodule Line do
  use WebSockex
  require Logger

  def connect(opts \\ []) do
    WebSockex.start_link("http://localhost:3000", __MODULE__, :state, opts)
  end

  def handshake(client) do
    json =
      %{
        n: "_h",
        i: "1",
        p: %{text: "handshake"}
      }
      |> Poison.encode!()

    WebSockex.send_frame(client, {:text, json})
  end

  def send(client, name, payload) do
    Logger.info("Sending event #{name} with payload")

    if is_binary(payload[:i]) do
      Logger.info("Message sent will wait for response")
    end

    json =
      %{
        n: name,
        p: payload
      }
      |> Poison.encode!()

    WebSockex.send_frame(client, {:text, json})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected")
    {:ok, state}
  end

  def handle_frame({:text, msg}, :state) do
    payload = Poison.decode!(msg, as: %Message{})

    case payload.n do
      "_p" ->
        Logger.info("Received ping/pong #{msg}")

        pong_message =
          %{
            n: "_p",
            i: payload.i
          }
          |> Poison.encode!()

        {:reply, {:text, pong_message}, :state}

      "_h" ->
        Logger.info("Received handshake #{msg}")
        {:reply, :state}

      "_r" ->
        Logger.info("Received response #{msg}")
        {:ok, :state}

      _ ->
        Logger.info("Received an unknown message #{msg}")

        message =
          %{
            n: "_r",
            i: payload.i
          }
          |> Poison.encode!()

        {:reply, {:text, message}, :state}
    end
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Disconnected with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end
