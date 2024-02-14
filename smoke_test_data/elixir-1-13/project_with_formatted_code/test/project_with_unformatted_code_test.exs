defmodule ProjectWithUnformattedCodeTest do
  use ExUnit.Case
  doctest ProjectWithUnformattedCode

  test "greets the world" do
    assert ProjectWithUnformattedCode.hello() == :world
  end
end
