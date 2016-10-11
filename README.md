# Brainfux

[![hex.pm version](https://img.shields.io/hexpm/v/brainfux.svg)](https://hex.pm/packages/brainfux)
![travis-ci status](https://travis-ci.org/SekiT/brainfux.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/SekiT/brainfux/badge.svg)](https://coveralls.io/github/SekiT/brainfux)

Brainfux enables you to define brainfuck function in elixir.

At the compile time,
* unmatched brackets are detected and an error is raised
* characters other than `+-><,.[]` are stripped
* `+-`, `-+`, `<>`, `><` are removed recursively
(for example, `++>>-+<<-` is turned into `+`)

## Installation

Add `:brainfux` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:brainfux, "~> 0.2.2"}]
end
```

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
