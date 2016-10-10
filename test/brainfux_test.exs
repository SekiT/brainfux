defmodule BrainfuxTest do
  use ExUnit.Case

  test "defbf defines module function" do
    defmodule DefBfTest do
      use Brainfux

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
      defbf echo ",[.,]"
      defbf shift_string ",[+.,]"
    end

    assert DefBfTest.hello_world         == "Hello, world!"
    assert DefBfTest.hello_world("foo")  == "Hello, world!"
    assert DefBfTest.echo("foo")         == "foo"
    assert DefBfTest.echo                == ""
    assert DefBfTest.shift_string("HAL") == "IBM"
    assert DefBfTest.shift_string        == ""
  end

  defmodule DefBfTypeSpecTest do
    use Brainfux
    defbf echo ",[.,]"

    # Getter for typespecs
    spec = Module.get_attribute(__MODULE__, :spec) |> Macro.escape
    def specs, do: unquote(spec)
  end

  test "defbf adds typespec" do
    specs = DefBfTypeSpecTest.specs
    |> Enum.map(fn {:spec, expr, _env} -> Macro.to_string(expr) end)

    assert "echo(String.t()) :: String.t()" in specs
  end

  test "defbf raises unexpected ]" do
    assert_raise CompileError, " Unexpected \"]\" at position: 1", fn ->
      defmodule EndNotStartedBracket do
        use Brainfux
        defbf echo ",].,"
      end
    end

    assert_raise CompileError, " Unexpected \"]\" at position: 5", fn ->
      defmodule TooMuchEndBracket do
        use Brainfux
        defbf echo ",[.],]"
      end
    end
  end

  test "defbf raises unmatched [" do
    assert_raise CompileError, " There are 2 unmatched \"[\"", fn ->
      defmodule NoEndBracket do
        use Brainfux
        defbf echo ",[.,["
      end
    end

    assert_raise CompileError, " There are 1 unmatched \"[\"", fn ->
      defmodule LackOfEndBracket do
        use Brainfux
        defbf echo ",[.[,]"
      end
    end
  end

  test "bfn defines anonymous function" do
    use Brainfux
    echo  = bfn ",[.,]"
    shift = bfn ",[+.,]"

    assert echo .("foo") == "foo"
    assert shift.("HAL") == "IBM"
  end

  test "bfn raises unexpected ]" do
    assert_raise CompileError, " Unexpected \"]\" at position: 1", fn ->
      # Here we define module and use bfn in it.
      # Otherwise it raises at compile time of this test code.
      defmodule EndNotStartedBracket do
        use Brainfux
        def echo(str) do
          (bfn ",].,[").(str)
        end
      end
    end

    assert_raise CompileError, " Unexpected \"]\" at position: 5", fn ->
      defmodule TooMuchEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.],]").(str)
        end
      end
    end
  end

  test "bfn raises unmatched [" do
    assert_raise CompileError, " There are 2 unmatched \"[\"", fn ->
      defmodule NoEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.,[").(str)
        end
      end
    end

    assert_raise CompileError, " There are 1 unmatched \"[\"", fn ->
      defmodule LackOfEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.[,]").(str)
        end
      end
    end
  end
end
