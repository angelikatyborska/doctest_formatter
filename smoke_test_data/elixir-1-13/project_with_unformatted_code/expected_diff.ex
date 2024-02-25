defmodule ExpectedDiff do
  def diff do
    """
    diff --git a/smoke_test_data/elixir-1-13/project_with_unformatted_code/lib/project_with_unformatted_code.ex b/smoke_test_data/elixir-1-13/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    index 4014a07..e1c0611 100644
    --- a/smoke_test_data/elixir-1-13/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    +++ b/smoke_test_data/elixir-1-13/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    @@ -12,8 +12,8 @@ defmodule ProjectWithUnformattedCode do
           3
    #{" "}
           iex> 1
    -      ...>   |> ProjectWithUnformattedCode.add(2)
    -          3
    +      ...> |> ProjectWithUnformattedCode.add(2)
    +      3
    #{" "}
       \"""
       def add(a, b) do
    @@ -21,10 +21,18 @@ defmodule ProjectWithUnformattedCode do
       end
    #{" "}
       @doc \"""
    -  iex>   ProjectWithUnformattedCode.subtract( 5, 4 )
    +  iex> ProjectWithUnformattedCode.subtract(5, 4)
       1
    #{" "}
    -  iex> [100_000_000_000, 200_000_000_000, 300_000_000_000, 400_000_000_000, 500_000_000_000, 600_000_000_000, 700_000_000_000]
    +  iex> [
    +  ...>   100_000_000_000,
    +  ...>   200_000_000_000,
    +  ...>   300_000_000_000,
    +  ...>   400_000_000_000,
    +  ...>   500_000_000_000,
    +  ...>   600_000_000_000,
    +  ...>   700_000_000_000
    +  ...> ]
       ...> |> Enum.map(&ProjectWithUnformattedCode.subtract(&1, 100_000_000_000))
       [0, 100_000_000_000, 200_000_000_000, 300_000_000_000, 400_000_000_000, 500_000_000_000, 600_000_000_000]
       \"""
    """
  end
end
