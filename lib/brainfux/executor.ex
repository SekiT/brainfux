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
    new_state = %{%{state | back: [head | state.back]} | forward: tail}
    execute(new_state, rest)
  end
  def execute(state, "<" <> rest) do
    [head | tail] = state.back
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
    [head | _] = state.forward
    if head == 0 do
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
    find_matching_bracket([], String.to_charlist(code), 0)
  end

  @spec find_matching_bracket(charlist, charlist, non_neg_integer) ::
    {String.t, String.t}
  defp find_matching_bracket(block, [?] | rest], 0) do
    {List.to_string(block), List.to_string(rest)}
  end
  defp find_matching_bracket(block, [?] | rest], depth) do
    find_matching_bracket(block ++ [?]], rest, depth - 1)
  end
  defp find_matching_bracket(block, [?[ | rest], depth) do
    find_matching_bracket(block ++ [?[], rest, depth + 1)
  end
  defp find_matching_bracket(block, [head | rest], depth) do
    find_matching_bracket(block ++ [head], rest, depth)
  end
end
