defmodule Message do
  @derive [Poison.Encoder]
  defstruct [:n, :p, :i, :e]
end
