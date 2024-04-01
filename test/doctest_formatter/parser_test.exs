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

    test "a single single-line doctest with other content in between" do
      assert parse("- foo\n- bar\niex> 1 + 2\n3") == [
               %OtherContent{lines: ["- foo", "- bar"]},
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 0}}
             ]

      assert parse("iex>1 + 2\n3\n\n- foo\n- bar") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 0}},
               %OtherContent{lines: ["", "- foo", "- bar"]}
             ]

      assert parse("# Hello, world!\n  iex> 1 + 2\n  3\n\n## Goodbye, Mars!") == [
               %OtherContent{lines: ["# Hello, world!"]},
               %DoctestExpression{lines: ["1 + 2"], result: ["  3"], indentation: {:spaces, 2}},
               %OtherContent{lines: ["", "## Goodbye, Mars!"]}
             ]
    end

    test "a single single-line doctest" do
      assert parse("iex> 1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 0}}
             ]

      assert parse("iex>1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 0}}
             ]

      assert parse("  iex>   1 + 2\n  3") == [
               %DoctestExpression{lines: ["  1 + 2"], result: ["  3"], indentation: {:spaces, 2}}
             ]

      assert parse("    iex> 1 + 2\n3") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 4}}
             ]
    end

    test "a single multi-line doctest" do
      assert parse("iex> 1 +\n...> 2 +\n...> 4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex>1 +\n...>2 +\n...>4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("  iex>   1 +\n  ...>   2 +\n  ...>   4\n  7") == [
               %DoctestExpression{
                 lines: ["  1 +", "  2 +", "  4"],
                 result: ["  7"],
                 indentation: {:spaces, 2}
               }
             ]

      assert parse("      iex> 1 +\n...> 2 +\n  ...> 4\n  7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["  7"],
                 indentation: {:spaces, 6}
               }
             ]
    end

    test "a single multi-line doctest with other content in between" do
      assert parse("a\nb\niex> 1 +\n...> 2 +\n...> 4\n7") == [
               %OtherContent{
                 lines: ["a", "b"]
               },
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex>1 +\n...>2 +\n...>4\n7\n\na\nb\n") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               },
               %OtherContent{
                 lines: ["", "a", "b", ""]
               }
             ]

      assert parse(
               "for example `iex>`, like this:\n  iex> 1 +\n  ...> 2 +\n  ...> 4\n  7\n\na\nb\n"
             ) == [
               %OtherContent{
                 lines: ["for example `iex>`, like this:"]
               },
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["  7"],
                 indentation: {:spaces, 2}
               },
               %OtherContent{
                 lines: ["", "a", "b", ""]
               }
             ]
    end

    test "a single multi-line doctest with 'iex>' on all lines" do
      assert parse("iex> 1 +\niex> 2 +\niex> 4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex>1 +\niex>2 +\niex>4\n7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("  iex> 1 +\n  iex> 2 +\n  iex> 4\n  7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["  7"],
                 indentation: {:spaces, 2}
               }
             ]

      assert parse("      iex> 1 +\niex> 2 +\n  iex> 4\n  7") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["  7"],
                 indentation: {:spaces, 6}
               }
             ]
    end

    test "doctests without results" do
      assert parse("    iex> 1 + 2\n") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %DoctestFormatter.OtherContent{lines: [""]}
             ]

      assert parse("    iex> 1 + 2\n  \n\n# Heading") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %OtherContent{lines: ["  ", "", "# Heading"]}
             ]

      assert parse("      iex> 1 +\n...> 2 +\n  ...> 4\n  ") == [
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: nil,
                 indentation: {:spaces, 6}
               },
               %OtherContent{lines: ["  "]}
             ]
    end

    test "multiple doctests" do
      assert parse("    iex> 1 + 2\n3\niex> 4 + 1\n5") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 4}},
               %DoctestExpression{lines: ["4 + 1"], result: ["5"], indentation: {:spaces, 0}}
             ]

      assert parse("    iex> 1 + 2\n\niex> 4 + 1\n") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %DoctestFormatter.OtherContent{lines: [""]},
               %DoctestExpression{lines: ["4 + 1"], result: nil, indentation: {:spaces, 0}},
               %DoctestFormatter.OtherContent{lines: [""]}
             ]

      assert parse("    iex> 1 + 2\n\n\niex> 4 + 1\n") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %OtherContent{lines: ["", ""]},
               %DoctestExpression{lines: ["4 + 1"], result: nil, indentation: {:spaces, 0}},
               %DoctestFormatter.OtherContent{lines: [""]}
             ]

      assert parse("    iex> 1 + 2\n\na\nb\niex> 1 +\n...> 2 +\n...> 4\n7") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %OtherContent{
                 lines: ["", "a", "b"]
               },
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("foo\n    iex> 1 + 2\n\na\nb\niex> 1 +\n...> 2 +\n...> 4\n7") == [
               %OtherContent{
                 lines: ["foo"]
               },
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %OtherContent{
                 lines: ["", "a", "b"]
               },
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("    iex> 1 + 2\n\niex> 1 +\n...> 2 +\n...> 4\n7") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %DoctestFormatter.OtherContent{lines: [""]},
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("    iex> 1 + 2\n\niex> 1 +\n...> 2 +\n...> 4\n7\niex> 4 +\n...> 1\n5") == [
               %DoctestExpression{lines: ["1 + 2"], result: nil, indentation: {:spaces, 4}},
               %DoctestFormatter.OtherContent{lines: [""]},
               %DoctestExpression{
                 lines: ["1 +", "2 +", "4"],
                 result: ["7"],
                 indentation: {:spaces, 0}
               },
               %DoctestExpression{
                 lines: ["4 +", "1"],
                 result: ["5"],
                 indentation: {:spaces, 0}
               }
             ]
    end

    test "a single doctest with multiline results" do
      assert parse("iex> ~T[01:02:03]\n%Time{\n  hour: 1\n  minute: 2\n  second: 3\n}") == [
               %DoctestExpression{
                 lines: ["~T[01:02:03]"],
                 result: ["%Time{", "  hour: 1", "  minute: 2", "  second: 3", "}"],
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex> ~T[01:02:03]\n%Time{\n  hour: 1\n  minute: 2\n  second: 3\n}\n") == [
               %DoctestExpression{
                 lines: ["~T[01:02:03]"],
                 result: ["%Time{", "  hour: 1", "  minute: 2", "  second: 3", "}"],
                 indentation: {:spaces, 0}
               },
               %DoctestFormatter.OtherContent{lines: [""]}
             ]
    end

    test "a single doctest with multiline results with other content in between" do
      assert parse(
               "## examples\niex> ~T[01:02:03]\n%Time{\n  hour: 1\n  minute: 2\n  second: 3\n}\n\n## something else"
             ) == [
               %OtherContent{
                 lines: ["## examples"]
               },
               %DoctestExpression{
                 lines: ["~T[01:02:03]"],
                 result: ["%Time{", "  hour: 1", "  minute: 2", "  second: 3", "}"],
                 indentation: {:spaces, 0}
               },
               %OtherContent{
                 lines: ["", "## something else"]
               }
             ]

      assert parse(
               "## examples\niex> ~T[01:02:03]\n%Time{\n  hour: 1\n  minute: 2\n  second: 3\n}\n   \n## something else"
             ) == [
               %OtherContent{
                 lines: ["## examples"]
               },
               %DoctestExpression{
                 lines: ["~T[01:02:03]"],
                 result: ["%Time{", "  hour: 1", "  minute: 2", "  second: 3", "}"],
                 indentation: {:spaces, 0}
               },
               %OtherContent{
                 lines: ["   ", "## something else"]
               }
             ]
    end

    test "multiple doctests with multiline results" do
      assert parse(
               "    iex> ~T[01:02:03]\n%Time{\n  hour: 1\n  minute: 2\n  second: 3\n}\niex> 4 + 1\n2 +\n3"
             ) == [
               %DoctestExpression{
                 lines: ["~T[01:02:03]"],
                 result: ["%Time{", "  hour: 1", "  minute: 2", "  second: 3", "}"],
                 indentation: {:spaces, 4}
               },
               %DoctestExpression{
                 lines: ["4 + 1"],
                 result: ["2 +", "3"],
                 indentation: {:spaces, 0}
               }
             ]
    end

    test "trailing newline" do
      assert parse("    iex> 1 + 2\n3\niex> 4 + 1\n5\n") == [
               %DoctestExpression{lines: ["1 + 2"], result: ["3"], indentation: {:spaces, 4}},
               %DoctestExpression{lines: ["4 + 1"], result: ["5"], indentation: {:spaces, 0}},
               %OtherContent{lines: [""]}
             ]

      assert parse("foo\n") == [
               %OtherContent{lines: ["foo", ""]}
             ]
    end

    test "with iex(n)>" do
      assert parse("    iex(3)> 1 + 2\n3") == [
               %DoctestExpression{
                 lines: ["1 + 2"],
                 result: ["3"],
                 iex_line_number: 3,
                 indentation: {:spaces, 4}
               }
             ]

      assert parse("iex(14)> 1 +\niex(2)> 2\n3") == [
               %DoctestExpression{
                 lines: ["1 +", "2"],
                 result: ["3"],
                 iex_line_number: 14,
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("iex(6)> 1 +\n...(6)> 2\n3") == [
               %DoctestExpression{
                 lines: ["1 +", "2"],
                 result: ["3"],
                 iex_line_number: 6,
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("  iex(6)> 1 +\n  ...(7)> 2\n3") == [
               %DoctestExpression{
                 lines: ["1 +", "2"],
                 result: ["3"],
                 iex_line_number: 6,
                 indentation: {:spaces, 2}
               }
             ]
    end

    test "iex()> counts as no line number" do
      assert parse("iex()> 1 + 2\n3") == [
               %DoctestExpression{
                 lines: ["1 + 2"],
                 result: ["3"],
                 iex_line_number: nil,
                 indentation: {:spaces, 0}
               }
             ]

      assert parse("  iex()> 1 +\n  iex()> 2\n3") == [
               %DoctestExpression{
                 lines: ["1 +", "2"],
                 result: ["3"],
                 iex_line_number: nil,
                 indentation: {:spaces, 2}
               }
             ]

      assert parse("iex()> 1 +\n...()> 2\n3") == [
               %DoctestExpression{
                 lines: ["1 +", "2"],
                 result: ["3"],
                 iex_line_number: nil,
                 indentation: {:spaces, 0}
               }
             ]
    end
  end
end
