defmodule DoctestFormatter.Formatter do
  @moduledoc false

  alias DoctestFormatter.{Parser, Indentation, OtherContent, DoctestExpression}
  require Logger

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

    doc_metadata = %{
      file: Keyword.get(opts, :file, "nofile"),
      loc_start: 0,
      attribute_name: nil
    }

    {forms, comments} = Code.string_to_quoted_with_comments!(content, to_quoted_opts)

    to_algebra_opts = [comments: comments, escape: false] ++ opts

    forms =
      Macro.prewalk(forms, fn node ->
        case node do
          {:@, meta1, [{attribute_name, meta2, [{:__block__, meta3, [doc_content]}]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) ->
            doc_metadata = %{
              doc_metadata
              | loc_start: Keyword.get(meta3, :line, 0),
                attribute_name: attribute_name
            }

            formatted_doc_content = format_doc_content(doc_content, opts, doc_metadata)
            {:@, meta1, [{attribute_name, meta2, [{:__block__, meta3, [formatted_doc_content]}]}]}

          {:@, meta1, [{attribute_name, meta2, [doc_content]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) ->
            doc_metadata = %{
              doc_metadata
              | loc_start: Keyword.get(meta2, :line, 0),
                attribute_name: attribute_name
            }

            formatted_doc_content = format_doc_content(doc_content, opts, doc_metadata)
            {:@, meta1, [{attribute_name, meta2, [formatted_doc_content]}]}

          {:@, meta1,
           [{attribute_name, meta2, [{sigil, meta3, [{:<<>>, meta4, [doc_content]}, []]}]}]}
          when attribute_name in [:doc, :moduledoc] and is_binary(doc_content) and
                 sigil in [:sigil_S, :sigil_s] ->
            doc_metadata = %{
              doc_metadata
              | loc_start: Keyword.get(meta4, :line, 0),
                attribute_name: attribute_name
            }

            formatted_doc_content = format_doc_content(doc_content, opts, doc_metadata)

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
    |> Code.quoted_to_algebra(to_algebra_opts)
    |> Inspect.Algebra.format(default_elixir_line_length())
    |> Kernel.++(["\n"])
    |> IO.iodata_to_binary()
  end

  defp format_doc_content(doc_content, opts, doc_metadata) do
    Parser.parse(doc_content)
    |> Enum.flat_map(fn chunk ->
      case chunk do
        %OtherContent{} -> chunk.lines
        %DoctestExpression{} -> do_format_expression(chunk, opts, doc_metadata)
      end
    end)
    |> Enum.join("\n")
  end

  def do_format_expression(%DoctestExpression{result: nil} = chunk, opts, doc_metadata) do
    format_lines(chunk, opts, doc_metadata)
  end

  def do_format_expression(%DoctestExpression{} = chunk, opts, doc_metadata) do
    format_lines(chunk, opts, doc_metadata) ++ format_result(chunk, opts, doc_metadata)
  end

  defp format_lines(chunk, opts, doc_metadata) do
    desired_line_length = Keyword.get(opts, :line_length, default_elixir_line_length())

    line_length =
      desired_line_length - elem(chunk.indentation, 1) - String.length(get_prompt(chunk, 0))

    opts = Keyword.put(opts, :line_length, line_length)

    string = Enum.join(chunk.lines, "\n")

    case try_format_string(string, opts, doc_metadata) do
      {:ok, formatted} ->
        formatted
        |> IO.iodata_to_binary()
        |> String.split("\n")

      :error ->
        chunk.lines
    end
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      Indentation.indent(get_prompt(chunk, index) <> line, chunk.indentation)
    end)
  end

  defp format_result(chunk, opts, doc_metadata) do
    desired_line_length = Keyword.get(opts, :line_length, default_elixir_line_length())

    line_length = desired_line_length - elem(chunk.indentation, 1)
    opts = Keyword.put(opts, :line_length, line_length)

    string_result =
      chunk.result
      |> Enum.join("\n")

    if exception_result?(string_result) || opaque_type_result?(string_result) do
      string_result
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        Indentation.indent(line, chunk.indentation)
      end)
    else
      case try_format_string(string_result, opts, doc_metadata) do
        {:ok, formatted} ->
          formatted
          |> IO.iodata_to_binary()
          |> String.split("\n")
          |> Enum.map(fn line ->
            Indentation.indent(line, chunk.indentation)
          end)

        :error ->
          chunk.result
      end
    end
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

  defp try_format_string(string, opts, doc_metadata) do
    try do
      {:ok, Code.format_string!(string, opts)}
    rescue
      error in SyntaxError ->
        message =
          """
          The @#{doc_metadata.attribute_name} attribute on #{Path.relative_to_cwd(doc_metadata.file)}:#{doc_metadata.loc_start} contains a doctest with some code that couldn't be formatted.

          The code:

          #{string}

          The error:

          #{inspect(error, pretty: true)}

          If this doctests compiles and passes when running `mix test`, then the problem lies with the formatter plugin `doctest_formatter`. Please check the list on known limitations of the plugin (https://github.com/angelikatyborska/doctest_formatter/#known-limitations). If none of them apply to your code, please open an issue (https://github.com/angelikatyborska/doctest_formatter/issues).
          """

        Logger.warning(message)

        :error
    end
  end
end
