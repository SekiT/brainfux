defmodule Brainfux.Preprocessor do
  @moduledoc """
  Preprocessor of brainfuck code.

  `process/1` conducts every process.
  """

  alias Brainfux.Preprocessor.Base

  @spec process!(String.t) :: String.t | none
  def process!(raw_code) do
    raw_code
    |> Base.strip_noncode_chars
    |> Base.check_brackets!
    |> Base.sumup_plusminus
    |> Base.sumup_rightleft
  end
end

defmodule Brainfux.Preprocessor.Base do
  @moduledoc """
  Basic functions of preprocessing code.

  These functions are used by `Brainfux.Preprocessor.process!/1`.
  """

  @spec strip_noncode_chars(String.t) :: String.t
  def strip_noncode_chars(code) do
    String.replace(code, ~r/[^+\-<>,\.\[\]]/, "")
  end

  @spec check_brackets!(String.t) :: String.t | none
  def check_brackets!(code) do
    check_brackets!(0, code, 0)
    code
  end

  @spec check_brackets!(non_neg_integer, String.t, non_neg_integer) :: :ok | none
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

  @spec sumup_plusminus(String.t) :: String.t
  def sumup_plusminus(code) do
    strip_plusminus = Regex.replace(~r/\+\-/, code           , "")
    strip_both      = Regex.replace(~r/\-\+/, strip_plusminus, "")
    if strip_both == code do
      code
    else
      sumup_plusminus(strip_both)
    end
  end

  @spec sumup_rightleft(String.t) :: String.t
  def sumup_rightleft(code) do
    strip_rightleft = Regex.replace(~r/></, code           , "")
    strip_both      = Regex.replace(~r/<>/, strip_rightleft, "")
    if strip_both == code do
      code
    else
      sumup_rightleft(strip_both)
    end
  end
end
