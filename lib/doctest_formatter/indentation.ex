defmodule DoctestFormatter.Indentation do
  @moduledoc false

  @type t :: {:tabs | :spaces, integer}

  @spec detect_indentation(String.t()) :: t()
  def detect_indentation(line) do
    cond do
      String.starts_with?(line, " ") ->
        indentation = String.length(line) - String.length(String.trim_leading(line, " "))
        {:spaces, indentation}

      String.starts_with?(line, "\t") ->
        indentation = String.length(line) - String.length(String.trim_leading(line, "\t"))
        {:tabs, indentation}

      true ->
        {:spaces, 0}
    end
  end

  def indent(line, {_, 0}) do
    line
  end

  def indent("", _), do: ""

  def indent(line, indentation) do
    indentation_string =
      case indentation do
        {:spaces, n} -> String.duplicate(" ", n)
        {:tabs, n} -> String.duplicate("\t", n)
      end

    indentation_string <> line
  end
end
