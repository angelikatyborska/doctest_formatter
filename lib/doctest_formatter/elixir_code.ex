defmodule DoctestFormatter.ElixirCode do
  @moduledoc false

  alias DoctestFormatter.Indentation

  defstruct([:lines, :indentation])

  @type t :: %__MODULE__{
          lines: [String.t()],
          indentation: Indentation.t()
        }
end
