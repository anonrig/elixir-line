# Line

Work in progress implementation of Line client in Elixir. Since, I'm a beginner and still learning Elixir, please point out my errors, my mistakes, so that I can learn quickly!

## Installation

Run `mix deps.get` on main root.

## Run

Run `iex -S mix` to run interactive elixir shell.

Then:

```elixir
{:ok, pid} = Line.connect()

Line.handshake(pid)

json =
  %{
    text: "yagiz",
    id: 1
  }
  |> Poison.encode!()

Line.send(pid, "hello", json)

Process.sleep(:infinity)
```

## Packages

- Poison - JSON encoding/decoding
- Websockex - Websocket implementation on Elixir.