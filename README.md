# Brainfux

Brainfux translates brainfuck code into elixir function with the great power of elixir macro.

## Usage

```elixir
defmodule Sample do
  use Brainfux

  # Define bf function
  defbf hello_world, """
    +++++++++
    [
      >++++++++
      >+++++++++++
      >+++++
      <<<-
    ]
    >.
    >++.+++++++..+++.
    >-.------------.
    <++++++++.--------.+++.------.--------.
    >+.
  """

  # bf function that reads input
  defbf echo, """
    [,.]
  """

  @spec shift_strings([String.t]) :: [String.t]
  def shift_stings(strings) do
    # The bfn macro makes an anonymous bf function
    Enum.map(strings, bfn "[,+.]")
  end
end

Sample.hello_world
# => "Hello, world!"

# You can pass string as an input
Sample.echo("foo")
# => "foo"

Sample.shift_strings(["abc", "HAL"])
# => ["bcd", "IBM"]
```
