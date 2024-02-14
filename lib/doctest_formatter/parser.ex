defmodule DoctestFormatter.Parser do
  @moduledoc false

  alias DoctestFormatter.ElixirCode
  alias DoctestFormatter.OtherContent
  alias DoctestFormatter.Indentation

  @spec parse(String.t()) :: [ElixirCode.t() | OtherContent.t()]
  def parse(content) do
    lines = String.split(content, "\n")

    parse_lines(lines, %{
      in_code_block: false,
      in_elixir_code_block: false,
      code_block_tag: nil,
      ignore_next_elixir_code_block: false,
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
      if acc.in_code_block do
        case code_block_end(line, acc.code_block_tag) do
          nil ->
            chunks = append_to_current_chunk(acc.chunks, line)
            %{acc | chunks: chunks}

          true ->
            chunks =
              if acc.in_elixir_code_block && !acc.ignore_next_elixir_code_block do
                [%OtherContent{lines: [line]} | acc.chunks]
              else
                append_to_current_chunk(acc.chunks, line)
              end

            %{
              acc
              | in_code_block: false,
                in_elixir_code_block: false,
                code_block_tag: nil,
                ignore_next_elixir_code_block: false,
                chunks: chunks
            }
        end
      else
        case code_block_start(line) do
          nil ->
            chunks = append_to_current_or_new_chunk(acc.chunks, %OtherContent{}, line)

            acc =
              if disable_comment(line) do
                %{acc | ignore_next_elixir_code_block: true}
              else
                acc
              end

            %{acc | chunks: chunks}

          {language, opening_tag} ->
            if language == "elixir" && !acc.ignore_next_elixir_code_block do
              chunks = append_to_current_or_new_chunk(acc.chunks, %OtherContent{}, line)

              chunks = [
                %ElixirCode{indentation: Indentation.detect_indentation(line), lines: []} | chunks
              ]

              %{
                acc
                | in_code_block: true,
                  in_elixir_code_block: true,
                  code_block_tag: opening_tag,
                  chunks: chunks
              }
            else
              chunks = append_to_current_or_new_chunk(acc.chunks, %OtherContent{}, line)

              %{
                acc
                | in_code_block: true,
                  in_elixir_code_block: false,
                  code_block_tag: opening_tag,
                  chunks: chunks
              }
            end
        end
      end

    parse_lines(rest, acc)
  end

  defp code_block_start(line) do
    case Regex.run(~r/(\s|\t)*(`{3,}|~{3,})([A-z]*)((\s|\t)*)$/, line) do
      nil ->
        nil

      [_, _indentation, opening_tag, language | _] ->
        {language, opening_tag}
    end
  end

  defp code_block_end(line, opening_tag) do
    case Regex.run(Regex.compile!("^(\\s*|\\t*)(#{opening_tag})(\\s*|\\t*)$"), line) do
      nil ->
        nil

      [_, _indentation, _closing_tag, _language | _] ->
        true
    end
  end

  defp disable_comment(line) do
    comment = "elixir-formatter-disable-next-block"

    # 'comments' are link references to '#' and can have one of the three formats:
    # ```
    # [optional-name]: # (elixir-formatter-disable-next-block)
    # [optional-name]: # "elixir-formatter-disable-next-block"
    # [optional-name]: # 'elixir-formatter-disable-next-block'

    case Regex.run(
           Regex.compile!(
             "^(\\s*|\\t*)\\[.*\\]: # ((\\(#{comment}\\))|(\"#{comment}\")|(\'#{comment}\'))(\\s*|\\t*)$"
           ),
           line
         ) do
      nil ->
        nil

      list when is_list(list) ->
        true
    end
  end

  defp append_to_current_or_new_chunk([], struct, line) do
    [%{struct | lines: [line]}]
  end

  defp append_to_current_or_new_chunk([current_chunk | rest], _, line) do
    [%{current_chunk | lines: [line | current_chunk.lines]} | rest]
  end

  defp append_to_current_chunk([current_chunk | rest], line) do
    [%{current_chunk | lines: [line | current_chunk.lines]} | rest]
  end
end
