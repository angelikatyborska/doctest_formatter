defmodule DoctestFormatter.Formatter do
  @moduledoc false

  alias DoctestFormatter.{Parser, Indentation, OtherContent, ElixirCode}

  @spec format(String.t(), keyword()) :: String.t()
  def format(content, opts) do
    Parser.parse(content)
    |> Enum.flat_map(fn chunk ->
      case chunk do
        %OtherContent{} -> chunk.lines
        %ElixirCode{} -> do_format_lines(chunk, opts)
      end
    end)
    |> Enum.join("\n")
  end

  def do_format_lines(%ElixirCode{} = chunk, opts) do
    chunk.lines
    |> Enum.join("\n")
    |> Code.format_string!(opts)
    |> IO.iodata_to_binary()
    |> String.split("\n")
    |> Enum.map(&Indentation.indent(&1, chunk.indentation))
  end
end
