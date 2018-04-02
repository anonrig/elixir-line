defmodule LineTest do
  use ExUnit.Case
  doctest Line

  test "greets the world" do
    assert Line.hello() == :world
  end
end
