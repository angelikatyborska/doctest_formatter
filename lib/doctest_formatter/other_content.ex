defmodule DoctestFormatter.OtherContent do
  @moduledoc false

  defstruct [:lines]

  @type t :: %__MODULE__{
          lines: [String.t()]
        }
end
