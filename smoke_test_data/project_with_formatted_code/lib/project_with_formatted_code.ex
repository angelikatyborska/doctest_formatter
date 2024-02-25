defmodule ProjectWithFormattedCode do
  @moduledoc """
  Documentation for `ProjectWithFormattedCode`.

  iex> ProjectWithFormattedCode.add(5, 5)
  10
  """

  @doc """
  Hello world.

  ## Examples

      iex> ProjectWithFormattedCode.add(1, 2)
      3

      iex> 1
      ...> |> ProjectWithFormattedCode.add(2)
      3

  """
  def add(a, b) do
    a + b
  end

  @doc """
  iex> ProjectWithFormattedCode.subtract(5, 4)
  1

  iex> [
  ...>   100_000_000_000,
  ...>   200_000_000_000,
  ...>   300_000_000_000,
  ...>   400_000_000_000,
  ...>   500_000_000_000,
  ...>   600_000_000_000,
  ...>   700_000_000_000
  ...> ]
  ...> |> Enum.map(&ProjectWithFormattedCode.subtract(&1, 100_000_000_000))
  [0, 100_000_000_000, 200_000_000_000, 300_000_000_000, 400_000_000_000, 500_000_000_000, 600_000_000_000]
  """
  def subtract(a, b) do
    a - b
  end
end
