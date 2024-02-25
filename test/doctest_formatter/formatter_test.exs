defmodule DoctestFormatter.FormatterTest do
  use ExUnit.Case

  import DoctestFormatter.Formatter

  describe "format/2 when no doctests" do
    test "works for empty strings" do
      assert format("", []) == "\n"
    end

    test "doesn't do anything when no docs and already formatted" do
      input =
        """
        defmodule Foo do
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == input
    end

    test "formats all elixir code because I don't know how not to do it" do
      input =
        """
        defmodule Foo do
          @spec add(a :: integer, b :: integer) :: integer
          def add(a,b) do
            a+b
          end


        end
        """

      desired_output =
        """
        defmodule Foo do
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "does not remove comments" do
      assert format("# foo", []) == "# foo\n"
    end

    test "keeps only one newline" do
      assert format("\n\n", []) == "\n"
    end
  end

  describe "format/2 on @docs" do
    test "formats doctests in docs, multiline string" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
          iex>     Foo.add(4,2)
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
          iex> Foo.add(4, 2)
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in docs, single line string" do
      input =
        """
        defmodule Foo do
          @doc \"It adds two numbers together\niex>     Foo.add(4,2)\n6\"
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"It adds two numbers together\niex> Foo.add(4, 2)\n6\"
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in docs, lowercase s sigil string" do
      input =
        """
        defmodule Foo do
          @doc ~s/It adds two numbers together\niex>     Foo.add(4,2)\n6/
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc ~s/It adds two numbers together\niex> Foo.add(4, 2)\n6/
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in docs, uppercase s sigil string" do
      input =
        """
        defmodule Foo do
          @doc ~S/It adds two numbers together
                  iex>     Foo.add(4,2)
                  6
                /
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc ~S/It adds two numbers together
                  iex> Foo.add(4, 2)
                  6
                /
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "keeps the indent level of the start of the code block" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
              iex>     Foo.add 4,2
              6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
              iex> Foo.add(4, 2)
              6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "respects formatter options" do
      opts = [locals_without_parens: [add: 2], force_do_end_blocks: true]

      input =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
          iex>   add 4,2
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It adds two numbers together
          iex> add 4, 2
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, opts)
      assert output == desired_output
    end

    test "multiline doctest" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>  "Fizz"
          ...>   |> concat( "Buzz" )
          ...> |>     concat("Barr")
                   "FizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex> "Fizz"
          ...> |> concat("Buzz")
          ...> |> concat("Barr")
          "FizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "multiline doctest with 'iex>' gets changed to '...>'" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>  "Fizz"
          iex>   |> concat( "Buzz" )
          iex> |>     concat("Barr")
                   "FizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex> "Fizz"
          ...> |> concat("Buzz")
          ...> |> concat("Barr")
          "FizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "doctest can get split into more lines than originally" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>  "Fizz" |> concat( "Buzz" ) |>     concat("Barr") |> List.duplicate(3) |> Enum.map(fn word -> String.upcase(word) end)
                   ["FIZZBUZZBARR", "FIZZBUZZBARR", "FIZZBUZZBARR"]
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex> "Fizz"
          ...> |> concat("Buzz")
          ...> |> concat("Barr")
          ...> |> List.duplicate(3)
          ...> |> Enum.map(fn word -> String.upcase(word) end)
          ["FIZZBUZZBARR", "FIZZBUZZBARR", "FIZZBUZZBARR"]
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "expected result can get split into more lines than originally" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>  "Fizz"
          ...>   |> concat( "Buzz" )
          ...> |>     concat("Barr")
          ...> |>     String.duplicate(20)
                   "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <> "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <> "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <> "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex> "Fizz"
          ...> |> concat("Buzz")
          ...> |> concat("Barr")
          ...> |> String.duplicate(20)
          "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <>
            "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <>
            "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr" <>
            "FizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarrFizzBuzzBarr"
          \"""
          @spec concat(a :: string, b :: string) :: string
          def concat(a, b) do
            a <> b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "multiple tests in single doc" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex>   Foo.add(3,4)
          7

          or

            iex> 3
            ...>    Foo.add( 7 )
                10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex> Foo.add(3, 4)
          7

          or

            iex> 3
            ...> Foo.add(7)
            10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "multiple docs in a single module" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex>   Foo.add(3,4)
          7

          or

            iex> 3
            ...>    Foo.add( 7 )
                10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end

          @doc \"""
          iex>   Foo.subtract(7,3)
          4

          or

            iex> 10
            ...>    Foo.subtract( 7 )
                3
          \"""
          @spec subtract(a :: integer, b :: integer) :: integer
          def subtract(a, b) do
            a - b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex> Foo.add(3, 4)
          7

          or

            iex> 3
            ...> Foo.add(7)
            10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end

          @doc \"""
          iex> Foo.subtract(7, 3)
          4

          or

            iex> 10
            ...> Foo.subtract(7)
            3
          \"""
          @spec subtract(a :: integer, b :: integer) :: integer
          def subtract(a, b) do
            a - b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "multiple modules" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex>   Foo.add(3,4)
          7

          or

            iex> 3
            ...>    Foo.add( 7 )
                10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end

        defmodule Bar do
          @doc \"""
          iex>   Bar.subtract(7,3)
          4

          or

            iex> 10
            ...>    Bar.subtract( 7 )
                3
          \"""
          @spec subtract(a :: integer, b :: integer) :: integer
          def subtract(a, b) do
            a - b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex> Foo.add(3, 4)
          7

          or

            iex> 3
            ...> Foo.add(7)
            10
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end

        defmodule Bar do
          @doc \"""
          iex> Bar.subtract(7, 3)
          4

          or

            iex> 10
            ...> Bar.subtract(7)
            3
          \"""
          @spec subtract(a :: integer, b :: integer) :: integer
          def subtract(a, b) do
            a - b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "adjust desired line length to fit the indentation and 'iex> '" do
      opts = [line_length: 30]

      input =
        """
        defmodule Foo do
          @doc \"""
                    iex> "a" <> "a" <> "a"
                    "aaa"
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
                    iex> "a" <>
                    ...>   "a" <> "a"
                    "aaa"
          \"""
        end
        """

      output = format(input, opts)
      assert output == desired_output
    end
  end

  describe "format/2 on @moduledocs" do
    test "formats doctests in moduledocs, multiline string" do
      input =
        """
        defmodule Foo do
          @moduledoc \"""
          It adds two numbers together
          iex>     Foo.add(4,2)
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @moduledoc \"""
          It adds two numbers together
          iex> Foo.add(4, 2)
          6
          \"""
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in moduledocs, single line string" do
      input =
        """
        defmodule Foo do
          @moduledoc \"It adds two numbers together\niex>     Foo.add(4,2)\n6\"
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @moduledoc \"It adds two numbers together\niex> Foo.add(4, 2)\n6\"
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in moduledocs, lowercase s sigil string" do
      input =
        """
        defmodule Foo do
          @moduledoc ~s/It adds two numbers together\niex>     Foo.add(4,2)\n6/
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @moduledoc ~s/It adds two numbers together\niex> Foo.add(4, 2)\n6/
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "formats doctests in moduledocs, uppercase s sigil string" do
      input =
        """
        defmodule Foo do
          @moduledoc ~S/It adds two numbers together
                  iex>     Foo.add(4,2)
                  6
                /
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @moduledoc ~S/It adds two numbers together
                  iex> Foo.add(4, 2)
                  6
                /
          @spec add(a :: integer, b :: integer) :: integer
          def add(a, b) do
            a + b
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end
  end

  # TODO: test string interpolation?
end
