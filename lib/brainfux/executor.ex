defmodule Brainfux.Executor do
  @moduledoc """
  The actual execution functions are here.

  Functions in this module are called runtime.
  """

  alias Brainfux.State

  @spec execute(State.t, String.t) :: State.t
  def execute(state, "") do
    state
  end
  def execute(state, "+" <> rest) do
    [head | tail] = state.forward
    new_state = %{state | forward: [head + 1 | tail]}
    execute(new_state, rest)
  end
  def execute(state, "-" <> rest) do
    [head | tail] = state.forward
    new_state = %{state | forward: [head - 1 | tail]}
    execute(new_state, rest)
  end
  def execute(state, ">" <> rest) do
    [head | tail] = state.forward
    tail = if Enum.empty?(tail), do: [0], else: tail
    new_state = %{%{state | back: [head | state.back]} | forward: tail}
    execute(new_state, rest)
  end
  def execute(state, "<" <> rest) do
    [head | tail] = state.back
    tail = if Enum.empty?(tail), do: [0], else: tail
    new_state = %{%{state | back: tail} | forward: [head | state.forward]}
    execute(new_state, rest)
  end
  def execute(state, "," <> rest) do
    [input_head | input_tail] = state.input
    [_ | forward_tail] = state.forward
    next_forward = [input_head | forward_tail]
    new_state = %{%{state | input: input_tail} | forward: next_forward}
    execute(new_state, rest)
  end
  def execute(state, "." <> rest) do
    [head | _] = state.forward
    new_state = %{state | output: state.output <> <<head>>}
    execute(new_state, rest)
  end
  def execute(state, "[" <> rest) do
    if hd(state.forward) == 0 do
      {_, rest} = find_matching_bracket(rest)
      execute(state, rest)
    else
      {block, _} = find_matching_bracket(rest)
      new_state = execute(state, block)
      execute(new_state, "[" <> rest)
    end
  end

  @spec find_matching_bracket(String.t) :: {String.t, String.t}
  defp find_matching_bracket(code) do
    find_matching_bracket("", code, 0)
  end

  @spec find_matching_bracket(String.t, String.t, non_neg_integer) ::
    {String.t, String.t}
  defp find_matching_bracket(block, code, depth) do
    case Regex.run(~R/([^\[\]]*)([\[\]])(.*)/, code) do
      nil ->
        {block, code}
      [_, before, "]", rest] ->
        if depth == 0 do
          {block <> before, rest}
        else
          find_matching_bracket(block <> before <> "]", rest, depth - 1)
        end
      [_, before, "[", rest] ->
        find_matching_bracket(block <> before <> "[", rest, depth + 1)
    end
  end
end
