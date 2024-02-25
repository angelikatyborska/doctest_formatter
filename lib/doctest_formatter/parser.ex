defmodule DoctestFormatter.Parser do
  @moduledoc false

  alias DoctestFormatter.DoctestExpression
  alias DoctestFormatter.OtherContent
  alias DoctestFormatter.Indentation

  @spec parse(String.t()) :: [DoctestExpression.t() | OtherContent.t()]
  def parse(content) do
    lines = String.split(content, "\n")

    parse_lines(lines, %{
      in_doctest: false,
      chunks: []
    })
  end

  defp parse_lines([], acc) do
    acc.chunks
    |> Enum.reverse()
    |> Enum.map(fn content ->
      %{content | lines: Enum.reverse(content.lines)}
    end)
  end

  defp parse_lines([line | rest], acc) do
    acc =
      if acc.in_doctest do
        case doctest_continuation(line) do
          nil ->
            %{acc | in_doctest: false}

          {:result, code} ->
            chunks = update_current_chunk(acc.chunks, fn chunk -> %{chunk | result: [code]} end)
            %{acc | in_doctest: false, chunks: chunks}

          {:continuation, code} ->
            chunks = append_to_current_chunk(acc.chunks, code)
            %{acc | chunks: chunks}
        end
      else
        case doctest_start(line) do
          nil ->
            chunks =
              append_to_current_or_new_chunk_of_same_type(acc.chunks, %OtherContent{}, line)

            %{acc | chunks: chunks}

          {:start, code} ->
            chunks = [
              %DoctestExpression{indentation: Indentation.detect_indentation(line), lines: [code]}
              | acc.chunks
            ]

            %{acc | in_doctest: true, chunks: chunks}
        end
      end

    parse_lines(rest, acc)
  end

  defp doctest_start(line) do
    case Regex.run(~r/^(\s|\t)*(iex>)\s?(.*)$/, line) do
      nil ->
        nil

      [_, _indentation, "iex>", code | _] ->
        {:start, code}
    end
  end

  defp doctest_continuation(line) do
    case Regex.run(~r/^(\s|\t)*((?:(?:\.\.\.)|(?:iex))>)\s?(.*)$/, line) do
      nil ->
        if String.trim(line) === "" do
          nil
        else
          {:result, line}
        end

      [_, _indentation, symbol, code | _] when symbol in ["iex>", "...>"] ->
        {:continuation, code}
    end
  end

  defp append_to_current_or_new_chunk_of_same_type([], struct, line) do
    [%{struct | lines: [line]}]
  end

  defp append_to_current_or_new_chunk_of_same_type(
         [%module{} = current_chunk | rest],
         %module{},
         line
       ) do
    [%{current_chunk | lines: [line | current_chunk.lines]} | rest]
  end

  defp append_to_current_or_new_chunk_of_same_type(list, struct, line) do
    [%{struct | lines: [line]} | list]
  end

  defp append_to_current_chunk([current_chunk | rest], line) do
    [%{current_chunk | lines: [line | current_chunk.lines]} | rest]
  end

  defp update_current_chunk([current_chunk | rest], func) do
    [func.(current_chunk) | rest]
  end
end
