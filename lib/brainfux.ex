defmodule Brainfux do
  @moduledoc """
  Translates brainfuck code into elixir function.
  """

  alias Brainfux.State

  @doc """
  Just import this module.
  """
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Define module function from brainfuck code.
  """
  defmacro defbf({name, _, [raw_code | _]}) do
    check_brackets(raw_code)
    code = strip_noncode_chars(raw_code)

    block = quote bind_quoted: [code: code] do
      alias Brainfux.{State, Executor}
      input_list = String.to_charlist(input) ++ [0]
      state = %State{input: input_list}
      %{output: output} = Executor.execute(state, code)
      output
    end

    quote do
      @spec unquote(name)(String.t) :: String.t
      def unquote(name)(input \\ ""), do: unquote(block)
    end
  end

  @doc """
  Define anonymous function from brainfuck code.
  """
  defmacro bfn(raw_code) do
    check_brackets(raw_code)
    code = strip_noncode_chars(raw_code)

    quote bind_quoted: [code: code] do
      fn input ->
        alias Brainfux.{State, Executor}
        input_list = String.to_charlist(input) ++ [0]
        state = %State{input: input_list}
        %{output: output} = Executor.execute(state, code)
        output
      end
    end
  end

  @spec check_brackets(String.t) :: :ok | none
  defp check_brackets(code) do
    check_brackets(0, code, 0)
  end

  @spec check_brackets(non_neg_integer, String.t, non_neg_integer) :: :ok | none
  defp check_brackets(_, "", 0), do: :ok
  defp check_brackets(_, "", depth) do
    raise CompileError, description: "There are #{depth} unmatched \"[\""
  end
  defp check_brackets(position, "]" <> _, 0) do
    raise CompileError, description: "Unexpected \"]\" at position: #{position}"
  end
  defp check_brackets(position, "]" <> rest, depth) do
    check_brackets(position + 1, rest, depth - 1)
  end
  defp check_brackets(position, "[" <> rest, depth) do
    check_brackets(position + 1, rest, depth + 1)
  end
  defp check_brackets(position, code, depth) do
    rest = Regex.replace(~r/./s, code, "", global: false)
    check_brackets(position + 1, rest, depth)
  end

  @spec strip_noncode_chars(String.t) :: String.t
  defp strip_noncode_chars(raw_code) do
    String.replace(raw_code, ~r/[^+\-<>,\.\[\]]/, "")
  end
end
