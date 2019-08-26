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
      defbf include_loop ",[[>]+[<]>-]"
    end

    assert DefBfTest.hello_world         == "Hello, world!"
    assert DefBfTest.hello_world("foo")  == "Hello, world!"
    assert DefBfTest.echo("foo")         == "foo"
    assert DefBfTest.echo                == ""
    assert DefBfTest.shift_string("HAL") == "IBM"
    assert DefBfTest.shift_string        == ""
    assert DefBfTest.include_loop("a")   == ""
  end

  defmodule DefBfTypeSpecTest do
    use Brainfux
    defbf echo ",[.,]"

    # Getter for typespecs
    spec = Module.get_attribute(__MODULE__, :spec) |> Macro.escape()
    def specs, do: unquote(spec)
  end

  test "defbf adds typespec" do
    [{:spec, expr, _env}] = DefBfTypeSpecTest.specs()

    assert Macro.to_string(expr) == "echo(String.t()) :: String.t()"
  end

  test "defbf raises unexpected ]" do
    assert_raise CompileError, ~S( Unexpected "]" at position: 1), fn ->
      defmodule EndNotStartedBracket do
        use Brainfux
        defbf echo ",].,"
      end
    end

    assert_raise CompileError, ~S( Unexpected "]" at position: 5), fn ->
      defmodule TooMuchEndBracket do
        use Brainfux
        defbf echo ",[.],]"
      end
    end
  end

  test "defbf raises unmatched [" do
    assert_raise CompileError, ~S( There are 2 unmatched "["), fn ->
      defmodule NoEndBracket do
        use Brainfux
        defbf echo ",[.,["
      end
    end

    assert_raise CompileError, ~S( There are 1 unmatched "["), fn ->
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
    loop  = bfn ",[[>]+[<]>-]"

    assert echo .("foo") == "foo"
    assert shift.("HAL") == "IBM"
    assert loop .("a"  ) == ""
  end

  test "bfn raises unexpected ]" do
    assert_raise CompileError, ~S( Unexpected "]" at position: 1), fn ->
      # Here we define module and use bfn in it.
      # Otherwise it raises at compile time of this test code.
      defmodule EndNotStartedBracket do
        use Brainfux
        def echo(str) do
          (bfn ",].,[").(str)
        end
      end
    end

    assert_raise CompileError, ~S( Unexpected "]" at position: 5), fn ->
      defmodule TooMuchEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.],]").(str)
        end
      end
    end
  end

  test "bfn raises unmatched [" do
    assert_raise CompileError, ~S( There are 2 unmatched "["), fn ->
      defmodule NoEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.,[").(str)
        end
      end
    end

    assert_raise CompileError, ~S( There are 1 unmatched "["), fn ->
      defmodule LackOfEndBracket do
        use Brainfux
        def echo(str) do
          (bfn ",[.[,]").(str)
        end
      end
    end
  end
end
