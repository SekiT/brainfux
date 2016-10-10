# Brainfux

Brainfux translates brainfuck code into elixir function.

At the compile time,
* unmatched brackets are detected and an error is raised
* characters other than `+-><,.[]` are stripped

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

Infinite loops are not detected at compile time, so the termination of functions are not ensured.
```elixir
use Brainfux

(bfn ",[+]").("a")
# => never ends

(bfn "+[>-]").("")
# => never ends
```
