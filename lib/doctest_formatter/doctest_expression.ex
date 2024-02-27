defmodule DoctestFormatter.DoctestExpression do
  @moduledoc false

  alias DoctestFormatter.Indentation

  defstruct([:lines, :result, :indentation, :iex_line_number])

  @type t :: %__MODULE__{
          lines: [String.t()],
          result: nil | [String.t()],
          indentation: Indentation.t(),
          iex_line_number: nil | pos_integer()
        }
end
