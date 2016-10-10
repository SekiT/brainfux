defmodule Brainfux do
  @moduledoc """
  Translates brainfuck code into elixir function.
  """

  alias Brainfux.{State, Preprocessor}

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
    code = Preprocessor.process!(raw_code)

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
    code = Preprocessor.process!(raw_code)

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
end
