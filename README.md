# Brainfux

Brainfux translates brainfuck code into elixir function with the great power of elixir macro.

At the compile time,
* used tape size is calculated so that runtime allocation will never happen
* unmatched brackets are detected and an error is raised
* `<<0>>` is appended to the input

## Usage

```elixir
defmodule Sample do
  use Brainfux

  # Define bf function
  defbf hello_world """
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
  defbf echo """
    ,[.,]
  """

  @spec shift_string(String.t) :: String.t
  def shift_string(str) do
    # The bfn macro makes an anonymous bf function
    (bfn ",[+.,]").(str)
  end
end

Sample.hello_world
# => "Hello, world!"

# You can pass string as an input
Sample.echo("foo")
# => "foo"

Sample.shift_string("HAL")
# => "IBM"
```

## Infinite loops

Infinite loops are not detected at compile time, so the termination of functions are not completely ensured.
```elixir
use Brainfux

(bfn ",[+]").("a")
# => never ends

(bfn "+[>+]").("")
# => ** (MatchError) no match of right hand side value: []
```
