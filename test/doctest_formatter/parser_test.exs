defmodule DoctestFormatter.ParserTest do
  use ExUnit.Case

  import DoctestFormatter.Parser
  alias DoctestFormatter.ElixirCode
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

    test "few lines, only elixir code, backticks" do
      assert parse("```elixir\n1 + 2\n```") == [
               %OtherContent{lines: ["```elixir"]},
               %ElixirCode{lines: ["1 + 2"], indentation: {:spaces, 0}},
               %OtherContent{lines: ["```"]}
             ]

      assert parse("  ```elixir\n  1 + 2\n  ```") == [
               %OtherContent{lines: ["  ```elixir"]},
               %ElixirCode{lines: ["  1 + 2"], indentation: {:spaces, 2}},
               %OtherContent{lines: ["  ```"]}
             ]

      assert parse("  `````elixir\n  1 + 2\n  `````") == [
               %OtherContent{lines: ["  `````elixir"]},
               %ElixirCode{lines: ["  1 + 2"], indentation: {:spaces, 2}},
               %OtherContent{lines: ["  `````"]}
             ]

      assert parse("    `````elixir\n    def add(a, b) do\n      a + b\n    end\n    `````") == [
               %OtherContent{lines: ["    `````elixir"]},
               %ElixirCode{
                 lines: ["    def add(a, b) do", "      a + b", "    end"],
                 indentation: {:spaces, 4}
               },
               %OtherContent{lines: ["    `````"]}
             ]
    end

    test "few lines, only elixir code, tildes" do
      assert parse("~~~elixir\n1 + 2\n~~~") == [
               %OtherContent{lines: ["~~~elixir"]},
               %ElixirCode{lines: ["1 + 2"], indentation: {:spaces, 0}},
               %OtherContent{lines: ["~~~"]}
             ]

      assert parse("  ~~~elixir\n  1 + 2\n  ~~~") == [
               %OtherContent{lines: ["  ~~~elixir"]},
               %ElixirCode{lines: ["  1 + 2"], indentation: {:spaces, 2}},
               %OtherContent{lines: ["  ~~~"]}
             ]

      assert parse("  ~~~~~elixir\n  1 + 2\n  ~~~~~") == [
               %OtherContent{lines: ["  ~~~~~elixir"]},
               %ElixirCode{lines: ["  1 + 2"], indentation: {:spaces, 2}},
               %OtherContent{lines: ["  ~~~~~"]}
             ]

      assert parse("    ~~~~~elixir\n    def add(a, b) do\n      a + b\n    end\n    ~~~~~") == [
               %OtherContent{lines: ["    ~~~~~elixir"]},
               %ElixirCode{
                 lines: ["    def add(a, b) do", "      a + b", "    end"],
                 indentation: {:spaces, 4}
               },
               %OtherContent{lines: ["    ~~~~~"]}
             ]
    end

    test "few lines, only javascript code" do
      assert parse("```js\n1 + 2\n```") == [
               %OtherContent{lines: ["```js", "1 + 2", "```"]}
             ]

      assert parse("  ~~~js\n  1 + 2\n  ~~~") == [
               %OtherContent{lines: ["  ~~~js", "  1 + 2", "  ~~~"]}
             ]

      assert parse("  `````js\n  1 + 2\n  `````") == [
               %OtherContent{lines: ["  `````js", "  1 + 2", "  `````"]}
             ]

      assert parse("  `````js\n  1 + 2\n  10 - 2\n  `````") == [
               %OtherContent{lines: ["  `````js", "  1 + 2", "  10 - 2", "  `````"]}
             ]
    end

    test "few lines, only code, no syntax specified" do
      assert parse("```\n1 + 2\n```") == [
               %OtherContent{lines: ["```", "1 + 2", "```"]}
             ]

      assert parse("  ~~~\n  1 + 2\n  ~~~") == [
               %OtherContent{lines: ["  ~~~", "  1 + 2", "  ~~~"]}
             ]

      assert parse("  `````\n  1 + 2\n  `````") == [
               %OtherContent{lines: ["  `````", "  1 + 2", "  `````"]}
             ]

      assert parse("  `````\n  1 + 2\n  10 - 2\n  `````") == [
               %OtherContent{lines: ["  `````", "  1 + 2", "  10 - 2", "  `````"]}
             ]
    end

    test "code block, no syntax specified, with an elixir code block as content" do
      result =
        """
        How to show your Elixir code on the forum:
        ````
        ```elixir
        %{foo: bar}
        ```
        ````
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to show your Elixir code on the forum:",
                   "````",
                   "```elixir",
                   "%{foo: bar}",
                   "```",
                   "````",
                   ""
                 ]
               }
             ]
    end

    test "elixir code block, with an elixir code block as content" do
      result =
        """
        Multiline strings in Elixir:
        ````elixir
        markdown =
          \"""
          ```elixir
          %{foo: bar}
          ```
          \"""
        ````
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "Multiline strings in Elixir:",
                   "````elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "markdown =",
                   "  \"\"\"",
                   "  ```elixir",
                   "  %{foo: bar}",
                   "  ```",
                   "  \"\"\""
                 ]
               },
               %OtherContent{
                 lines: [
                   "````",
                   ""
                 ]
               }
             ]
    end

    test "multiple code blocks" do
      result =
        """
        How to show your Elixir code on the forum:
        ````
        ```elixir
        %{foo: bar}
        ```
        ````

        How to define a function in Elixir:
        ~~~elixir
        defmodule MyModule do
          def my_function(a, b), do: a + b
        end
        ~~~

        How to define a macro in Elixir:
        ```elixir
        defmodule MyModule do
          defmacro my_macro(a, b), do: a + b
        end
        ```
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to show your Elixir code on the forum:",
                   "````",
                   "```elixir",
                   "%{foo: bar}",
                   "```",
                   "````",
                   "",
                   "How to define a function in Elixir:",
                   "~~~elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "defmodule MyModule do",
                   "  def my_function(a, b), do: a + b",
                   "end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "~~~",
                   "",
                   "How to define a macro in Elixir:",
                   "```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "defmodule MyModule do",
                   "  defmacro my_macro(a, b), do: a + b",
                   "end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "```",
                   ""
                 ]
               }
             ]
    end

    test "inline code" do
      result =
        """
        Define a function with `def` or `defp` if it's private.
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "Define a function with `def` or `defp` if it's private.",
                   ""
                 ]
               }
             ]
    end

    test "indented code block" do
      result =
        """
        - How to define a function in Elixir:
          ~~~elixir
          defmodule MyModule do
            def my_function(a, b), do: a + b
          end
          ~~~

        - How to define a macro in Elixir:
          ```elixir
          defmodule MyModule do
            defmacro my_macro(a, b), do: a + b
          end
          ```
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "- How to define a function in Elixir:",
                   "  ~~~elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 2},
                 lines: [
                   "  defmodule MyModule do",
                   "    def my_function(a, b), do: a + b",
                   "  end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "  ~~~",
                   "",
                   "- How to define a macro in Elixir:",
                   "  ```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 2},
                 lines: [
                   "  defmodule MyModule do",
                   "    defmacro my_macro(a, b), do: a + b",
                   "  end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "  ```",
                   ""
                 ]
               }
             ]
    end

    test "a caveat: non-fenced code blocks aren't handled correctly" do
      # elixir code as content in a non-fenced code block (indented) should be treated as "other content"
      # but it's not, it's treated as Elixir code
      result =
        """
        How to show your Elixir code on the forum:

            ```elixir
            %{foo: bar}
            ```
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to show your Elixir code on the forum:",
                   "",
                   "    ```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 4},
                 lines: [
                   "    %{foo: bar}"
                 ]
               },
               %OtherContent{
                 lines: [
                   "    ```",
                   ""
                 ]
               }
             ]
    end
  end

  describe "parse/1 with disable comments" do
    test "disable 'comment' treats the next Elixir code block like other content" do
      result =
        """
        ```elixir
        %{foo: bar}
        ```

        How to define a function in Elixir:

        [//]: # (elixir-formatter-disable-next-block)

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~

        How to define a macro in Elixir:
        ```elixir
        defmodule MyModule do
          defmacro my_macro(a, b), do: a + b
        end
        ```
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "%{foo: bar}"
                 ]
               },
               %OtherContent{
                 lines: [
                   "```",
                   "",
                   "How to define a function in Elixir:",
                   "",
                   "[//]: # (elixir-formatter-disable-next-block)",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   "",
                   "How to define a macro in Elixir:",
                   "```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "defmodule MyModule do",
                   "  defmacro my_macro(a, b), do: a + b",
                   "end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "```",
                   ""
                 ]
               }
             ]
    end

    test "each Elixir code block needs its own comment" do
      result =
        """
        ```elixir
        %{foo: bar}
        ```

        How to define a function in Elixir:

        [//]: # (elixir-formatter-disable-next-block)

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~

        How to define a macro in Elixir:

        [//]: # (elixir-formatter-disable-next-block)

        ```elixir
        defmodule MyModule do
          defmacro my_macro(a, b), do: a + b
        end
        ```
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "```elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "%{foo: bar}"
                 ]
               },
               %OtherContent{
                 lines: [
                   "```",
                   "",
                   "How to define a function in Elixir:",
                   "",
                   "[//]: # (elixir-formatter-disable-next-block)",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   "",
                   "How to define a macro in Elixir:",
                   "",
                   "[//]: # (elixir-formatter-disable-next-block)",
                   "",
                   "```elixir",
                   "defmodule MyModule do",
                   "  defmacro my_macro(a, b), do: a + b",
                   "end",
                   "```",
                   ""
                 ]
               }
             ]
    end

    test "'comment' reference name can be empty" do
      result =
        """
        How to define a function in Elixir:

        []: # (elixir-formatter-disable-next-block)

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "[]: # (elixir-formatter-disable-next-block)",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "'comment' reference name can be anything" do
      result =
        """
        How to define a function in Elixir:

        [foo-bar-baz]: # (elixir-formatter-disable-next-block)

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "[foo-bar-baz]: # (elixir-formatter-disable-next-block)",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "link title can be in single quotes" do
      result =
        """
        How to define a function in Elixir:

        [//]: # 'elixir-formatter-disable-next-block'

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "[//]: # 'elixir-formatter-disable-next-block'",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "link title can be in double quotes" do
      result =
        """
        How to define a function in Elixir:

        [//]: # "elixir-formatter-disable-next-block"

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "[//]: # \"elixir-formatter-disable-next-block\"",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "link href must be #" do
      result =
        """
        How to define a function in Elixir:

        [//]: https://exercism.org "elixir-formatter-disable-next-block"

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "[//]: https://exercism.org \"elixir-formatter-disable-next-block\"",
                   "",
                   "~~~elixir"
                 ]
               },
               %ElixirCode{
                 indentation: {:spaces, 0},
                 lines: [
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end"
                 ]
               },
               %OtherContent{
                 lines: [
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "'comment' does not need to be followed by the block immediately" do
      result =
        """
        []: # (elixir-formatter-disable-next-block)

        How to define a function in Elixir:

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "[]: # (elixir-formatter-disable-next-block)",
                   "",
                   "How to define a function in Elixir:",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end

    test "'comment' can wrapped in whitespace" do
      # note: I'm not sure if that's valid Markdown syntax

      result =
        """
        How to define a function in Elixir:

        \t  []: # (elixir-formatter-disable-next-block)\t#{"  "}

        ~~~elixir
        defmodule MyModule do
                 def my_function(a,b), do: a+b
        end
        ~~~
        """
        |> parse()

      assert result == [
               %OtherContent{
                 lines: [
                   "How to define a function in Elixir:",
                   "",
                   "\t  []: # (elixir-formatter-disable-next-block)\t  ",
                   "",
                   "~~~elixir",
                   "defmodule MyModule do",
                   "         def my_function(a,b), do: a+b",
                   "end",
                   "~~~",
                   ""
                 ]
               }
             ]
    end
  end
end
