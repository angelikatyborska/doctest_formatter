defmodule DoctestFormatter.Formatter do
  @moduledoc false

  alias DoctestFormatter.{Parser, Indentation, OtherContent, DoctestExpression}

  @spec format(String.t(), keyword()) :: String.t()
  def format(content, opts) do
    # TODO: can I rely on the default already being set?
    # TODO: I should subtract the indentation level from the default
    line_length = Keyword.get(opts, :line_length, 98)

    to_quoted_opts =
      [
        unescape: false,
        literal_encoder: &{:ok, {:__block__, &2, [&1]}},
        token_metadata: true,
        emit_warnings: false
      ] ++ opts

    {forms, comments} = Code.string_to_quoted_with_comments!(content, to_quoted_opts)

    to_algebra_opts = [comments: comments] ++ opts

    forms =
      Macro.prewalk(forms, fn node ->
        case node do
          {:@, meta1, [{:doc, meta2, [{:__block__, meta3, [doc_content]}]}]}
          when is_binary(doc_content) ->
            formatted_doc_content = format_doc_content(doc_content, opts)
            {:@, meta1, [{:doc, meta2, [{:__block__, meta3, [formatted_doc_content]}]}]}

          {:@, meta1, [{:doc, meta2, [doc_content]}]} when is_binary(doc_content) ->
            formatted_doc_content = format_doc_content(doc_content, opts)
            {:@, meta1, [{:doc, meta2, [formatted_doc_content]}]}

          {:@, meta1, [{:doc, meta2, [{sigil, meta3, [{:<<>>, meta4, [doc_content]}, []]}]}]}
          when is_binary(doc_content) and sigil in [:sigil_S, :sigil_s] ->
            formatted_doc_content = format_doc_content(doc_content, opts)

            {:@, meta1,
             [{:doc, meta2, [{sigil, meta3, [{:<<>>, meta4, [formatted_doc_content]}, []]}]}]}

          node ->
            node
        end
      end)

    forms
    |> Code.Formatter.to_algebra(to_algebra_opts)
    |> Inspect.Algebra.format(line_length)
    |> Kernel.++(["\n"])
    |> IO.iodata_to_binary()
  end

  defp format_doc_content(doc_content, opts) do
    Parser.parse(doc_content)
    |> Enum.flat_map(fn chunk ->
      case chunk do
        %OtherContent{} -> chunk.lines
        %DoctestExpression{} -> do_format_expression(chunk, opts)
      end
    end)
    |> Enum.join("\n")
  end

  def do_format_expression(%DoctestExpression{} = chunk, opts) do
    formatted_lines =
      chunk.lines
      |> Enum.join("\n")
      |> Code.format_string!(opts)
      |> IO.iodata_to_binary()
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.map(fn {line, index} ->
        symbol = if(index == 0, do: "iex", else: "...")
        Indentation.indent("#{symbol}> " <> line, chunk.indentation)
      end)

    result_opts = Keyword.put(opts, :line_length, :infinity)

    formatted_result =
      Code.format_string!(chunk.result, result_opts)
      |> IO.iodata_to_binary()
      |> Indentation.indent(chunk.indentation)

    formatted_lines ++ [formatted_result]
  end
end
