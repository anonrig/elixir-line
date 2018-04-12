defmodule Line do
  use WebSockex
  require Logger
  require UUID

  def connect(opts \\ []) do
    {:ok, pid} = WebSockex.start("ws://localhost:3000", __MODULE__, :state, opts)

    Logger.debug("Handshake started")
    handshakeTask = Task.async(fn -> Line.handshake(pid) end)
    Logger.debug("Handshake ended")

    Task.await(handshakeTask)
    pid
  end

  def handshake(pid) do
    json =
      %{
        n: "_h",
        i: UUID.uuid1(),
        p: %{text: "handshake"}
      }
      |> Poison.encode!()

    WebSockex.send_frame(pid, {:text, json})
  end

  def send(client, name, payload) do
    id = UUID.uuid1()
    Logger.info("Sending event #{name} with id #{id}")

    json = %{
      n: name,
      p: payload,
      i: id
    }

    WebSockex.send_frame(client, {:text, json |> Poison.encode!()})
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected")
    {:ok, state}
  end

  def handle_frame({:text, msg}, :state) do
    payload = Poison.decode!(msg, as: %Message{})

    case payload.n do
      "_p" ->
        Logger.debug("Received ping/pong #{msg}")

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
        if payload.p != "pong" do
          Logger.info("Received response #{msg}")
        end

        {:ok, :state}

      _ ->
        Logger.info("Received an unknown message #{msg}")

        if is_integer(payload.i) do
          # Waiting for response.
        end

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
