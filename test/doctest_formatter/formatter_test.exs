defmodule DoctestFormatter.FormatterTest do
  use ExUnit.Case

  import DoctestFormatter.Formatter

  describe "format/2" do
    test "works for empty strings" do
      assert format("", []) == ""
    end

    test "doesn't do anything when no elixir code" do
      input =
        """
        # Hello, World!

        There is no Elixir code in this document.

        * List item 1
        * List item 2

        ```js
        console.log('hello')
        ```

         - weird
               - formatting in Markdown
            - is not this plugin's concern!
        """

      output = format(input, [])
      assert output == input
    end

    test "formats elixir code in code blocks" do
      input =
        """
        # Hello, World!

        * List item 1
        * List item 2

        ```elixir
              def add(a, b), do:    a+b
        ```

        ## Goodbye, Mars!

        ~~~~elixir
        1+2+3+4
        ~~~~
        """

      desired_output =
        """
        # Hello, World!

        * List item 1
        * List item 2

        ```elixir
        def add(a, b), do: a + b
        ```

        ## Goodbye, Mars!

        ~~~~elixir
        1 + 2 + 3 + 4
        ~~~~
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "ignores non-Elixir code blocks" do
      input =
        """
        # Hello, World!

        * List item 1
        * List item 2

        ```plaintext
              def add(a, b), do:    a+b
        ```
        """

      output = format(input, [])
      assert output == input
    end

    test "keeps the indent level of the start of the code block" do
      input =
        """
        - one
        - two
            - two and a half:
              ```elixir
                    def add a, b do
                                a + b
                      end
              ```
            - two and three quarters
        """

      desired_output =
        """
        - one
        - two
            - two and a half:
              ```elixir
              def add(a, b) do
                a + b
              end
              ```
            - two and three quarters
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "respects formatter options" do
      opts = [locals_without_parens: [add: 2], force_do_end_blocks: true]

      input =
        """
        # Hello, World!

        * List item 1
        * List item 2

        ```elixir
              def add(a, b), do:    a+b

          def subtract(a, b) do
          add a, -1*b
          end
        ```
        """

      desired_output =
        """
        # Hello, World!

        * List item 1
        * List item 2

        ```elixir
        def add(a, b) do
          a + b
        end

        def subtract(a, b) do
          add a, -1 * b
        end
        ```
        """

      output = format(input, opts)
      assert output == desired_output
    end

    test "empty lines with whitespace only should keep their whitespace, but not in Elixir" do
      input =
        """
        # Hello, World!

        #{"\t\t\t"}
        #{"    "}
        ```elixir
        def add(a, b) do
          dbg(a)

          dbg(b)
        #{"\t"}
          dbg(a + b)
        #{"  "}
          a + b
        end
        ```
        """

      desired_output =
        """
        # Hello, World!

        #{"\t\t\t"}
        #{"    "}
        ```elixir
        def add(a, b) do
          dbg(a)

          dbg(b)

          dbg(a + b)

          a + b
        end
        ```
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "respects 'disable comments'" do
      input =
        """
        # Hello, World!

        * List item 1
        * List item 2

        [//]: # (elixir-formatter-disable-next-block)

        ```elixir
              def add(a, b), do:    a+b
        ```

        ## Goodbye, Mars!

        ~~~~elixir
        1+2+3+4
        ~~~~
        """

      desired_output =
        """
        # Hello, World!

        * List item 1
        * List item 2

        [//]: # (elixir-formatter-disable-next-block)

        ```elixir
              def add(a, b), do:    a+b
        ```

        ## Goodbye, Mars!

        ~~~~elixir
        1 + 2 + 3 + 4
        ~~~~
        """

      output = format(input, [])
      assert output == desired_output
    end
  end
end
