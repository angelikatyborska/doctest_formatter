defmodule DoctestFormatter.FormatterTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import DoctestFormatter.Formatter

  test "exception_result?/1" do
    assert exception_result?("** (RuntimeError) some error")
    assert exception_result?("   ** (RuntimeError) some error  ")
    assert exception_result?("\t** (SomeError) ")
    assert exception_result?("  ** ( ")

    refute exception_result?("**")
    refute exception_result?("*")
    refute exception_result?("")
    refute exception_result?("3 + 4")
  end

  test "opaque_type_result?/1" do
    assert opaque_type_result?("#User<>")
    assert opaque_type_result?("  #User<>  ")
    assert opaque_type_result?("\t#User<>  ")
    assert opaque_type_result?("#Accounts.User<>")
    assert opaque_type_result?("#Accounts.User<name: \"something\">")
    assert opaque_type_result?("#Accounts.User<name: \"something\", ...>")
    assert opaque_type_result?("#SomeModule345<>")
    assert opaque_type_result?("#Foo.SomeModule345<>")
    assert opaque_type_result?("#DateTime<2023-06-26 09:30:00+09:00 JST Asia/Tokyo>")

    refute opaque_type_result?("#")
    refute opaque_type_result?("# ")
    refute opaque_type_result?("# comment")
    refute opaque_type_result?("#not_a_module")
    refute opaque_type_result?("")
    refute opaque_type_result?("3 + 2")
  end

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

  describe "format/2 on single line doctests" do
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

    test "different integer formats" do
      input =
        """
        defmodule IntegerFormats do
          @doc \"""
            iex> ?A
            0x41

            iex> 0b1000001
            65

            iex> 0x00
            0b00

            iex> 0b1000001
            65
          \"""

          def func do
            [?A, ?B, ?C]
            [0x41, 0x42, 0x43]
            [0b1000001, 0b1000010, 0b1000011]
          end
        end
        """

      desired_output =
        """
        defmodule IntegerFormats do
          @doc \"""
            iex> ?A
            0x41

            iex> 0b1000001
            65

            iex> 0x00
            0b00

            iex> 0b1000001
            65
          \"""

          def func do
            [?A, ?B, ?C]
            [0x41, 0x42, 0x43]
            [0b1000001, 0b1000010, 0b1000011]
          end
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "keeps line number in iex>() prompt" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex(4)>   add 4,2
          6
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex(4)> add(4, 2)
          6
          \"""
        end
        """

      output = format(input, [])
      assert output == desired_output
    end

    test "doctests with no expected result" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>    concat("Fizz","Buzz")
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
          iex> concat("Fizz", "Buzz")
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
  end

  describe "format/2 on multiline doctests" do
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

    test "multiline doctest with no expected result" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
          iex>  "Fizz"
          ...>   |> concat( "Buzz" )
          ...> |>     concat("Barr")

          Bla bla
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

          Bla bla
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

    test "multiline doctest with 'iex(n)>' gets changed to '...(n)>'" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex(3)>  "Fizz"
          iex()>   |> concat( "Buzz" )
          iex()> |>     concat("Barr")
                   "FizzBuzzBarr"
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex(3)> "Fizz"
          ...(3)> |> concat("Buzz")
          ...(3)> |> concat("Barr")
          "FizzBuzzBarr"
          \"""
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
  end

  describe "format/2 indentation" do
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

    test "multiline expected result indentation" do
      input =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
              iex>   ~T[01:02:03]
              %Time{
                  hour: 1,
                  minute: 2,
                  second: 3
              }
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          It concatenates two strings together
              iex> ~T[01:02:03]
              %Time{
                hour: 1,
                minute: 2,
                second: 3
              }
          \"""
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
            ...>    |> Foo.add( 7 )
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
            ...> |> Foo.add(7)
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

    test "adjust desired test code line length to fit the indentation and 'iex> '" do
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

    test "adjust desired result line length to fit the indentation" do
      opts = [line_length: 30]

      input =
        """
        defmodule Foo do
          @doc \"""
                        iex> "aaa"
                        "a" <> "a" <> "a"
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
                        iex> "aaa"
                        "a" <>
                          "a" <> "a"
          \"""
        end
        """

      output = format(input, opts)
      assert output == desired_output
    end

    test "uses the desired line length for the non-doctest code too" do
      # 300 is much longer than the default 98 chars, if the formatter doesn't respect the option of 300 chars,
      # it would try to split the long lines into multiple lines
      opts = [line_length: 300]

      input =
        """
        defmodule Foo do
          @doc \"""
                        iex> "aaa"
                        "a" <> "a" <> "a"
          \"""
          def my_long_function(argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8) do
            (1000 + argument1 + argument2 + argument3 + argument4 + argument5 + argument6 + argument7 + argument8) * 2
          end
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
                        iex> "aaa"
                        "a" <> "a" <> "a"
          \"""
          def my_long_function(argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8) do
            (1000 + argument1 + argument2 + argument3 + argument4 + argument5 + argument6 + argument7 + argument8) * 2
          end
        end
        """

      output = format(input, opts)
      assert output == desired_output
    end

    test "does not create trailing spaces" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex>   x = 3#{" "}
          iex> #{"   "}
          iex>    y = 4#{"   "}
          iex>#{}
          iex>    Foo.add(x,y)#{"   "}
          7
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
          iex> x = 3
          ...>
          ...> y = 4
          ...>
          ...> Foo.add(x, y)
          7
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
  end

  describe "format/2 on exceptions" do
    test "can handle exceptions in results" do
      input =
        """
        defmodule Foo do
          @doc \"""
          iex>  "Fizz"
          iex>   |> Kernel.<>( "Buzz" )
          iex> |>     Kernel.<>(nil)
                   ** (ArgumentError) expected binary argument in <> operator but got: nil
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          @doc \"""
          iex> "Fizz"
          ...> |> Kernel.<>("Buzz")
          ...> |> Kernel.<>(nil)
          ** (ArgumentError) expected binary argument in <> operator but got: nil
          \"""
        end
        """

      output = format(input, [])
      assert output == desired_output
    end
  end

  describe "format/2 on opaque types" do
    test "can handle exceptions in results" do
      input =
        """
        defmodule Foo do
          defmodule User do
            @derive {Inspect, only: [:name]}
            defstruct [:name, :email]
          end

          @doc \"""
          iex>    %Foo.User{name: "Bob", email: "bob123@example.com"}
              #Foo.User<name: "Bob", ...>
          \"""
        end
        """

      desired_output =
        """
        defmodule Foo do
          defmodule User do
            @derive {Inspect, only: [:name]}
            defstruct [:name, :email]
          end

          @doc \"""
          iex> %Foo.User{name: "Bob", email: "bob123@example.com"}
          #Foo.User<name: "Bob", ...>
          \"""
        end
        """

      output = format(input, [])
      assert output == desired_output
    end
  end

  describe "format/2 on content loaded from file" do
    # bring to light bugs that might be hidden because of inline-heredoc-string-code formatting, like in the above test files
    test "double-escaped quotes cannot be helped, prints a warning and leaves unchanged" do
      input =
        File.read!(Path.join(__DIR__, "../fixtures/escaped_quotes.ex"))

      desired_output =
        File.read!(Path.join(__DIR__, "../fixtures/escaped_quotes_desired_output.ex"))

      io =
        capture_log(fn ->
          output = format(input, [])
          assert output == desired_output
        end)

      assert io =~
               "[warning] The @doc attribute on nofile:3 contains a doctest with some code that couldn't be formatted."

      assert io =~ "SyntaxError"
    end
  end
end
