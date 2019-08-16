defmodule Brainfux do
  @moduledoc """
  Translates brainfuck code into elixir function.
  """

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
    block = exec_block(raw_code)
    quote do
      @spec unquote(name)(String.t) :: String.t
      def unquote(name)(input \\ ""), do: unquote(block)
    end
  end

  @doc """
  Define anonymous function from brainfuck code.
  """
  defmacro bfn(raw_code) do
    block = exec_block(raw_code)
    quote do
      fn input -> unquote(block) end
    end
  end

  @spec exec_block(String.t) :: Macro.t
  defp exec_block(raw_code) do
    {state, code} = Brainfux.Preprocessor.process!(raw_code)
    %{back: back, forward: forward, output: output} = state

    quote bind_quoted: [
      back:    back,
      forward: forward,
      output:  output,
      code:    code,
    ] do
      input_list = String.to_charlist(input) ++ [0]
      state = %Brainfux.State{
        back:    back,
        forward: forward,
        input:   input_list,
        output:  output,
      }
      %{output: result} = Brainfux.Executor.execute(state, code)
      result
    end
  end
end
