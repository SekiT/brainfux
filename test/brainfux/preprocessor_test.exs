defmodule Brainfux.PreprocessorTest do
  use ExUnit.Case
  alias Brainfux.Preprocessor
  alias Brainfux.Preprocessor.Base

  test "process!/1 just pipes code through base functions" do
    on_exit fn ->
      :meck.unload
    end

    :meck.expect(Base, :strip_noncode_chars, fn code ->
      assert code == "+-++--+ foo ><>><<>\n --bar++ \t<<>>+---><<<"
      "+-++--+><>><<>--++<<>>+---><<<"
    end)
    :meck.expect(Base, :check_brackets!, fn code ->
      assert code == "+-++--+><>><<>--++<<>>+---><<<"
      code
    end)
    :meck.expect(Base, :sumup_plusminus, fn code ->
      assert code == "+-++--+><>><<>--++<<>>+---><<<"
      "+>--<<"
    end)

    code = Preprocessor.process!("+-++--+ foo ><>><<>\n --bar++ \t<<>>+---><<<")

    assert code == "+>--<<"
  end

  test "process!/1 does every process" do
    raw_code = "+-++--+ foo ><>><<>\n --bar++ \t<<>>+---><<<"
    expected = "+>--<<"

    assert Preprocessor.process!(raw_code) == expected
  end

  test "Base.strip_noncode_chars/1" do
    code_expected_map = %{
      "" => "",
      " " => "",
      "+++\n[-]" => "+++[-]",
      "+72." => "+.",
    }
    Enum.each(code_expected_map, fn {code, expected} ->
      assert Base.strip_noncode_chars(code) == expected
    end)
  end

  test "Base.check_brackets!/1" do
    valid_codes = [
      "[]",
      "+[-]",
      "[>+++[>++<-]<-]",
      "+[>+[-]<[-]]",
    ]
    Enum.each(valid_codes, fn code ->
      assert Base.check_brackets!(code) == code
    end)

    code_message_map = %{
      "]"       => " Unexpected \"]\" at position: 0",
      "+]"      => " Unexpected \"]\" at position: 1",
      "+[[]-]]" => " Unexpected \"]\" at position: 6",
      "+[[]"    => " There are 1 unmatched \"[\"",
      "[[++>"   => " There are 2 unmatched \"[\"",
    }
    Enum.each(code_message_map, fn {code, message} ->
      assert_raise(CompileError, message, fn ->
        Base.check_brackets!(code)
      end)
    end)
  end

  test "Base.sumup_plusminus" do
    code_expected_map = %{
      "+++++"    => "+++++",
      "-----"    => "-----",
      "+-"       => "",
      "-+"       => "",
      "++--+"    => "+",
      "--++-"    => "-",
      "-++++"    => "+++",
      "+----"    => "---",
      ">>>>>"    => ">>>>>",
      "<<<<<"    => "<<<<<",
      "><"       => "",
      "<>"       => "",
      ">><<>"    => ">",
      "<<>><"    => "<",
      "<>>>>"    => ">>>",
      "><<<<"    => "<<<",
      "++>>+"    => "++>>+",
      "--<<-"    => "--<<-",
      "+<>-"     => "",
      "-><+"     => "",
      "++><-"    => "+",
      "--<>+"    => "-",
      ">>+-<"    => ">",
      "<<-+>"    => "<",
      "+>>-+<<-" => "",
      ">++<>--<" => "",
      "+[->]<"   => "+[->]<",
      ">[<-]+"   => ">[<-]+",
    }
    Enum.each(code_expected_map, fn {code, expected} ->
      assert Base.sumup_plusminus(code) == expected
    end)
  end
end
