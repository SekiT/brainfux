defmodule Brainfux.Preprocessor do
  @moduledoc """
  Preprocessor of brainfuck code.

  `process/1` conducts every process.
  """

  alias Brainfux.Preprocessor.Base
  alias Brainfux.State

  @spec process!(String.t) :: {State.t, String.t} | none
  def process!(raw_code) do
    raw_code
    |> Base.check_brackets!
    |> Base.strip_noncode_chars
    |> Base.trim_trailing_reducible_part
    |> Base.sumup_plusminus
    |> Base.remove_plus_or_minus_before_read
    |> Base.compute_deterministic_part
  end
end

defmodule Brainfux.Preprocessor.Base do
  @moduledoc """
  Basic functions of preprocessing code.

  These functions are used by `Brainfux.Preprocessor.process!/1`.
  """

  alias Brainfux.{State, Executor}

  @spec check_brackets!(String.t) :: String.t | none
  def check_brackets!(code) do
    check_brackets!(0, code, 0)
    code
  end

  @spec check_brackets!(non_neg_integer, String.t, non_neg_integer) ::
    :ok | none
  defp check_brackets!(_, "", 0), do: :ok
  defp check_brackets!(_, "", depth) do
    raise CompileError, description: "There are #{depth} unmatched \"[\""
  end
  defp check_brackets!(position, "]" <> _, 0) do
    raise CompileError, description: "Unexpected \"]\" at position: #{position}"
  end
  defp check_brackets!(position, "]" <> rest, depth) do
    check_brackets!(position + 1, rest, depth - 1)
  end
  defp check_brackets!(position, "[" <> rest, depth) do
    check_brackets!(position + 1, rest, depth + 1)
  end
  defp check_brackets!(position, code, depth) do
    rest = Regex.replace(~r/./s, code, "", global: false)
    check_brackets!(position + 1, rest, depth)
  end

  @spec strip_noncode_chars(String.t) :: String.t
  def strip_noncode_chars(code) do
    String.replace(code, ~r/[^+\-<>,\.\[\]]/, "")
  end

  @spec trim_trailing_reducible_part(String.t) :: String.t
  def trim_trailing_reducible_part(code) do
    last_part = String.split(code, ".") |> List.last
    reducible_part = skip_to_close_bracket(last_part, 0, "", "")
    if reducible_part == "" do
      code
    else
      String.trim_trailing(code, reducible_part)
    end
  end

  @spec skip_to_close_bracket(String.t, integer, String.t, String.t) :: String.t
  defp skip_to_close_bracket(code, depth, inner, outer) do
    case Regex.run(~r/^([^\[\]]*([\[\]]))(.*)/, code) do
      nil ->
        outer <> code
      [_, match, "[", rest] ->
        skip_to_close_bracket(rest, depth + 1, inner, outer <> match)
      [_, match, "]", rest] ->
        if depth == 0 do
          skip_to_close_bracket(rest, 0, inner <> outer <> match, "")
        else
          skip_to_close_bracket(rest, depth - 1, inner, outer <> match)
        end
    end
  end

  @spec sumup_plusminus(String.t) :: String.t
  def sumup_plusminus(code) do
    stripped_once = Regex.replace(~r/\+\-|\-\+|><|<>/, code, "")

    if stripped_once == code do
      code
    else
      sumup_plusminus(stripped_once)
    end
  end

  @spec remove_plus_or_minus_before_read(String.t) :: String.t
  def remove_plus_or_minus_before_read(code) do
    Regex.replace(~r/([\+\-]+),/, code, ",")
  end

  @spec compute_deterministic_part(String.t) :: {State.t, String.t}
  def compute_deterministic_part(code) do
    case Regex.run(~r/^[\+\-<>\.]+/, code) do
      nil ->
        {%State{}, code}
      [deterministic_part] ->
        state = Executor.execute(%State{}, deterministic_part)
        rest = String.trim_leading(code, deterministic_part)
        {state, rest}
    end
  end
end
