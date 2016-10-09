defmodule Brainfux.State do
  @moduledoc """
  Struct that represents the state of execution.
  """

  defstruct input: '', output: "", back: [], forward: []

  @type t :: %__MODULE__{
    input:   charlist,
    output:  String.t,
    back:    [integer],
    forward: [integer],
  }
end
