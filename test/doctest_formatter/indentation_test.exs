defmodule DoctestFormatter.IndentationTest do
  use ExUnit.Case

  import DoctestFormatter.Indentation

  describe "detect_indentation/1" do
    test "tells apart tabs from spaces" do
      assert detect_indentation("\t") == {:tabs, 1}
      assert detect_indentation(" ") == {:spaces, 1}
    end

    test "counts tabs" do
      assert detect_indentation("\t") == {:tabs, 1}
      assert detect_indentation("\t\t") == {:tabs, 2}
      assert detect_indentation("\t\t\t") == {:tabs, 3}
      assert detect_indentation("\t\t\t\t\t\t\t\t\t\t\t\t\t") == {:tabs, 13}
    end

    test "counts spaces" do
      assert detect_indentation("") == {:spaces, 0}
      assert detect_indentation("  ") == {:spaces, 2}
      assert detect_indentation("   ") == {:spaces, 3}
      assert detect_indentation("       ") == {:spaces, 7}
    end

    test "stops counting after any other character" do
      assert detect_indentation("foo\tbar") == {:spaces, 0}
      assert detect_indentation("\tfoo\tbar") == {:tabs, 1}
      assert detect_indentation("\t\t- one") == {:tabs, 2}
      assert detect_indentation("   - one") == {:spaces, 3}
      assert detect_indentation("    ```elixir") == {:spaces, 4}
    end

    test "stops counting after the other indentation character" do
      assert detect_indentation("\t   ") == {:tabs, 1}
      assert detect_indentation("\t\t   ") == {:tabs, 2}
      assert detect_indentation("\t\t \t") == {:tabs, 2}
      assert detect_indentation("   \t   ") == {:spaces, 3}
      assert detect_indentation("         \t") == {:spaces, 9}
    end
  end

  describe "indent/2" do
    test "no indentation" do
      assert indent("- foo", {:spaces, 0}) == "- foo"
      assert indent("   ### Bar", {:spaces, 0}) == "   ### Bar"
    end

    test "tabs" do
      assert indent("- foo", {:tabs, 2}) == "\t\t- foo"
      assert indent("\t\t\tBar", {:tabs, 10}) == "\t\t\t\t\t\t\t\t\t\t\t\t\tBar"
    end

    test "spaces" do
      assert indent("def foo, do: 3", {:spaces, 2}) == "  def foo, do: 3"
      assert indent("   40_000", {:spaces, 7}) == "          40_000"
    end

    test "does not indent empty lines" do
      assert indent("", {:spaces, 1}) == ""
      assert indent("", {:tabs, 1}) == ""
      assert indent("  ", {:spaces, 1}) == "   "
      assert indent("  \t\t", {:tabs, 1}) == "\t  \t\t"
    end
  end
end
