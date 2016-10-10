defmodule Brainfux.State do
  @moduledoc """
  Struct that represents the state of execution.
  """

  defstruct input: '', output: "", back: [0], forward: [0]

  @type t :: %__MODULE__{
    input:   charlist,
    output:  String.t,
    back:    [integer],
    forward: [integer],
  }
end
