defmodule ExpectedDiff do
  def diff do
    """
    diff --git a/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex b/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    index 730bd33..53fdd6d 100644
    --- a/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    +++ b/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    @@ -2,7 +2,7 @@ defmodule ProjectWithUnformattedCode do
       @moduledoc """
       Documentation for `ProjectWithUnformattedCode`.
  #{" "}
    -  iex> ProjectWithFormattedCode.add(5,5)
    +  iex> ProjectWithFormattedCode.add(5, 5)
       10
       \"""
    #{" "}
    @@ -15,8 +15,8 @@ defmodule ProjectWithUnformattedCode do
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
    @@ -24,10 +24,18 @@ defmodule ProjectWithUnformattedCode do
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
