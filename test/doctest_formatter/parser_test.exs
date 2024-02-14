defmodule DoctestFormatter.ParserTest do
  use ExUnit.Case

  import DoctestFormatter.Parser
  alias DoctestFormatter.DoctestExpression
  alias DoctestFormatter.OtherContent

  describe "parse/1" do
    test "one line, no code" do
      assert parse("") == [%OtherContent{lines: [""]}]
      assert parse("abc") == [%OtherContent{lines: ["abc"]}]
      assert parse("    ") == [%OtherContent{lines: ["    "]}]
    end

    test "few lines, no code" do
      assert parse("# Hello, World!\n\nLorem ipsum.") == [
               %OtherContent{lines: ["# Hello, World!", "", "Lorem ipsum."]}
             ]

      assert parse("  - one\n  - two\n") == [%OtherContent{lines: ["  - one", "  - two", ""]}]
    end

    test "only single-line doctests" do
      assert parse("iex> 1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: "3", indentation: {:spaces, 0}}
             ]

      assert parse("iex>1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: "3", indentation: {:spaces, 0}}
             ]

      assert parse("  iex> 1 + 2\n  3") == [
               %DoctestExpression{lines: ["1 + 2"], result: "  3", indentation: {:spaces, 2}}
             ]

      assert parse("    iex> 1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: "3", indentation: {:spaces, 4}}
             ]
    end

    test "only multi-line doctests" do
      assert parse("iex> 1 +\n...> 2 +\n...> 4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: "7",
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex>1 +\n...>2 +\n...>4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: "7",
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("  iex> 1 +\n  ...> 2 +\n  ...> 4\n  7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: "  7",
                 indentation: {:spaces, 2}
               }
             ]

      assert parse("      iex> 1 +\n...> 2 +\n  ...> 4\n  7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: "  7",
                 indentation: {:spaces, 6}
               }
             ]
    end
  end
end
