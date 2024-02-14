defmodule ProjectWithUnformattedCode do
  @moduledoc """
  Documentation for `ProjectWithUnformattedCode`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ProjectWithUnformattedCode.hello()
      :world

  """
  def hello do
    ~M"""
    # Hello, World!

    ```elixir
    def add(a, b), do: a + b
    ```

    ```js
    1+2+3
    ```
    """

    :world
  end
end
