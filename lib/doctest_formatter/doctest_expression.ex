defmodule DoctestFormatter.DoctestExpression do
  @moduledoc false

  alias DoctestFormatter.Indentation

  defstruct([:lines, :result, :indentation])

  @type t :: %__MODULE__{
          lines: [String.t()],
          result: nil | String.t(),
          indentation: Indentation.t()
        }
end
