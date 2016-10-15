defmodule Brainfux.PreprocessorTest do
  use ExUnit.Case
  alias Brainfux.{Preprocessor, State}
  alias Brainfux.Preprocessor.Base

  test "process!/1 just pipes code through base functions" do
    on_exit fn ->
      :meck.unload
    end

    :meck.expect(Base, :check_brackets!, fn code ->
      assert code == "+>+<->\n<++A-\t [--+<].>>-,-<<"
      code
    end)
    :meck.expect(Base, :strip_noncode_chars, fn code ->
      assert code == "+>+<->\n<++A-\t [--+<].>>-,-<<"
      "+>+<-><++-[--+<].>>-,-<<"
    end)
    :meck.expect(Base, :sumup_plusminus, fn code ->
      assert code == "+>+<-><++-[--+<].>>-,-<<"
      "+>+<[-<].>>-,-<<"
    end)
    :meck.expect(Base, :remove_plus_or_minus_before_read, fn code ->
      assert code == "+>+<[-<].>>-,-<<"
      "+>+<[-<].>>,-<<"
    end)
    :meck.expect(Base, :compute_deterministic_part, fn code ->
      assert code == "+>+<[-<].>>,-<<"
      {%State{forward: [1, 1]}, "[-<].>>,-<<"}
    end)

    {state, code} = Preprocessor.process!("+>+<->\n<++A-\t [--+<].>>-,-<<")

    assert {state, code} == {%State{forward: [1, 1]}, "[-<].>>,-<<"}
  end

  test "process!/1 does every process" do
    raw_code = "+>+<->\n<++A-\t [--+<].>>-,-<<"
    expected_state = %State{forward: [1, 1]}
    expected_code = "[-<].>>,-<<"

    assert Preprocessor.process!(raw_code) == {expected_state, expected_code}
  end

  test "Base.strip_noncode_chars/1" do
    code_expected_map = %{
      ""        => "",
      " "       => "",
      "++\n[-]" => "++[-]",
      "+72."    => "+.",
      ",>\t<."  => ",><.",
    }
    Enum.each(code_expected_map, fn {code, expected} ->
      assert Base.strip_noncode_chars(code) == expected
    end)
  end

  test "Base.check_brackets!/1" do
    valid_codes = [
      "",
      "+.",
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
      "foo]"    => " Unexpected \"]\" at position: 3",
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
      ""         => "",
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

  test "Base.remove_plus_or_minus_before_read" do
    code_expected_map = %{
      ""       => "",
      "+"      => "+",
      "--,"    => ",",
      "<++,"   => "<,",
      ">--,"   => ">,",
      ">+,<+," => ">,<,",
      ",-->-," => ",-->,",
    }
    Enum.each(code_expected_map, fn {code, expected} ->
      assert Base.remove_plus_or_minus_before_read(code) == expected
    end)
  end

  test "Base.compute_deterministic_part" do
    raw_code_state_after_code_list = [
      {""    , %State{}, ""},
      {"+"   , %State{forward: [1]}, ""},
      {"-"   , %State{forward: [-1]}, ""},
      {">"   , %State{back: [0, 0]}, ""},
      {"<"   , %State{forward: [0, 0]}, ""},
      {"+."  , %State{forward: [1], output: <<1>>}, ""},
      {"+.>-", %State{back: [1, 0], forward: [-1], output: <<1>>}, ""},
      {"++,-", %State{forward: [2]}, ",-"},
      {"-[+]", %State{forward: [-1]}, "[+]"},
    ]
    Enum.each(raw_code_state_after_code_list,
      fn {raw_code, state, after_code} ->
        assert {state, after_code} == Base.compute_deterministic_part(raw_code)
      end
    )
  end
end
