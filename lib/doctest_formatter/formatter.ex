defmodule DoctestFormatter.Formatter do
  @moduledoc false

  alias DoctestFormatter.{Parser, Indentation, OtherContent, DoctestExpression}

  defp default_elixir_line_length, do: 98

  @spec format(String.t(), keyword()) :: String.t()
  def format(content, opts) do
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
          {:@, meta1, [{attribute_name, meta2, [{:__block__, meta3, [doc_content]}]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) ->
            formatted_doc_content = format_doc_content(doc_content, opts)
            {:@, meta1, [{attribute_name, meta2, [{:__block__, meta3, [formatted_doc_content]}]}]}

          {:@, meta1, [{attribute_name, meta2, [doc_content]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) ->
            formatted_doc_content = format_doc_content(doc_content, opts)
            {:@, meta1, [{attribute_name, meta2, [formatted_doc_content]}]}

          {:@, meta1,
           [{attribute_name, meta2, [{sigil, meta3, [{:<<>>, meta4, [doc_content]}, []]}]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) and
                 sigil in [:sigil_S, :sigil_s] ->
            formatted_doc_content = format_doc_content(doc_content, opts)

            {:@, meta1,
             [
               {attribute_name, meta2,
                [{sigil, meta3, [{:<<>>, meta4, [formatted_doc_content]}, []]}]}
             ]}

          node ->
            node
        end
      end)

    forms
    |> Code.Formatter.to_algebra(to_algebra_opts)
    |> Inspect.Algebra.format(default_elixir_line_length())
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

  def do_format_expression(%DoctestExpression{result: nil} = chunk, opts) do
    format_lines(chunk, opts)
  end

  def do_format_expression(%DoctestExpression{} = chunk, opts) do
    format_lines(chunk, opts) ++ format_result(chunk, opts)
  end

  defp format_lines(chunk, opts) do
    desired_line_length = Keyword.get(opts, :line_length, default_elixir_line_length())

    line_length =
      desired_line_length - elem(chunk.indentation, 1) - String.length(get_prompt(chunk, 0))

    opts = Keyword.put(opts, :line_length, line_length)

    chunk.lines
    |> Enum.join("\n")
    |> Code.format_string!(opts)
    |> IO.iodata_to_binary()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      Indentation.indent(get_prompt(chunk, index) <> line, chunk.indentation)
    end)
  end

  defp format_result(chunk, opts) do
    desired_line_length = Keyword.get(opts, :line_length, default_elixir_line_length())

    line_length = desired_line_length - elem(chunk.indentation, 1)
    opts = Keyword.put(opts, :line_length, line_length)

    string_result =
      chunk.result
      |> Enum.join("\n")

    string_result =
      if exception_result?(string_result) || opaque_type_result?(string_result) do
        string_result
        |> String.trim()
      else
        string_result
        |> Code.format_string!(opts)
        |> IO.iodata_to_binary()
      end

    string_result
    |> String.split("\n")
    |> Enum.map(fn line ->
      Indentation.indent(line, chunk.indentation)
    end)
  end

  def exception_result?(string) do
    string |> String.trim() |> String.starts_with?("** (")
  end

  def opaque_type_result?(string) do
    string |> String.trim() |> String.match?(~r/#([A-z0-9\.]*)<(.*)>/)
  end

  defp get_prompt(chunk, line_index) do
    iex_line_number =
      if chunk.iex_line_number do
        "(#{chunk.iex_line_number})"
      else
        ""
      end

    prompt_text =
      if line_index == 0 do
        "iex"
      else
        "..."
      end

    "#{prompt_text}#{iex_line_number}> "
  end
end
