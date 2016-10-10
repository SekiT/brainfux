defmodule Brainfux.StateTest do
  use ExUnit.Case, async: true
  alias Brainfux.State

  test "default state" do
    assert %State{} == %State{input: '', output: "", back: [], forward: []}
  end
end
