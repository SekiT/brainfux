defmodule Brainfux.ExecutorTest do
  use ExUnit.Case
  alias Brainfux.{Executor, State}

  test "execute one operation" do
    state = Executor.execute(%State{forward: [0]}, "+")
    assert state == %State{forward: [1]}

    state = Executor.execute(%State{forward: [0]}, "-")
    assert state == %State{forward: [-1]}

    state = Executor.execute(%State{forward: [0, 1]}, ">")
    assert state == %State{back: [0], forward: [1]}

    state = Executor.execute(%State{back: [0], forward: [1]}, "<")
    assert state == %State{forward: [0, 1]}

    state = Executor.execute(%State{input: 'a' ++ [0], forward: [0]}, ",")
    assert state == %State{input: [0], forward: [?a]}

    state = Executor.execute(%State{forward: [42]}, ".")
    assert state == %State{forward: [42], output: <<42>>}
  end

  test "execute loop" do
    state = Executor.execute(%State{forward: [2, 0]}, "[>+++<-]")
    assert state == %State{forward: [0, 6]}

    state = Executor.execute(%State{forward: [2, 0, 0]}, "[>+++[>++<-]<-]")
    assert state == %State{forward: [0, 0, 12]}
  end

  test "output is string" do
    state = Executor.execute(%State{input: 'foo' ++ [0], forward: [0]}, ",[.,]")
    assert state == %State{forward: [0], output: "foo"}
  end
end
