defmodule ProjectWithUnformattedCode do
  @moduledoc """
  Documentation for `ProjectWithUnformattedCode`.

  iex> ProjectWithUnformattedCode.add(5,5)
  10
  """

  @doc """
  Hello world.

  ## Examples

      iex> ProjectWithUnformattedCode.add(1, 2)
      3

      iex> 1
      ...>   |> ProjectWithUnformattedCode.add(2)
      3

  """
  def add(a, b) do
    a + b
  end

  @doc """
  iex>   ProjectWithUnformattedCode.subtract( 5, 4 )
  1

  iex> [100_000_000_000, 200_000_000_000, 300_000_000_000, 400_000_000_000, 500_000_000_000, 600_000_000_000, 700_000_000_000]
  ...> |> Enum.map(&ProjectWithUnformattedCode.subtract(&1, 100_000_000_000))
  [0, 100_000_000_000, 200_000_000_000, 300_000_000_000, 400_000_000_000, 500_000_000_000, 600_000_000_000]
  """
  def subtract(a, b) do
    a - b
  end

  defmodule User do
    @derive {Inspect, only: [:name]}
    defstruct [:name, :email]
  end

  @doc """
      iex>   ProjectWithUnformattedCode.alice()
      #ProjectWithUnformattedCode.User<name: "Alice", ...>
  """
  def alice do
    %User{name: "Alice", email: "alice99@example.com"}
  end
end
