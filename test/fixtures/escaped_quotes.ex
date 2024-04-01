defmodule EscapedQuotes do
  # this doctest will not be fully formatted
  @doc """
       iex>     %{
       iex>   data:    "{\\"supply\\": 100}"
       iex> }
       %{data:
        "{\\"supply\\": 100}"}
  """

  # but this one will
  @doc ~S"""
       iex>     %{
       ...>   data:    "{\"supply\": 100}"
       ...> }
       %{data:
        "{\"supply\": 100}"}
  """
end
