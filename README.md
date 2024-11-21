# Doctest Formatter

![GitHub Workflow status](https://github.com/angelikatyborska/doctest_formatter/actions/workflows/test.yml/badge.svg)
![version on Hex.pm](https://img.shields.io/hexpm/v/doctest_formatter)
![number of downloads on Hex.pm](https://img.shields.io/hexpm/dt/doctest_formatter)
![license on Hex.pm](https://img.shields.io/hexpm/l/doctest_formatter)

An Elixir formatter for doctests.

![Running mix format formats your doctests](https://raw.github.com/angelikatyborska/doctest_formatter/main/assets/mix-format.gif)

## Installation

The package can be installed by adding `doctest_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doctest_formatter, "~> 0.3.1", runtime: false}
  ]
end
```

Then, extend your `.formatter.exs` config file by adding the plugin. 

```elixir
# .formatter.exs
[
  plugins: [DoctestFormatter],
  inputs: [
    # your usual inputs ...
  ]
]
```

Elixir 1.13.2 or up is required. Versions lower than 1.13 do not support formatter plugins, and versions 1.13.0 and 1.13.1 do not support formatter plugins for `.ex` files.

## Usage

Run `mix format`.

This formatter plugin will not only format the Elixir code inside the doctest, but it will format the test's `iex>` prompt as well. It will always use `iex>` for the first line of the test, and `...>` for each next line. For example:

```elixir
@doc """
  iex> "Hello, " <>
    iex> "World!"
"""

# becomes:

@doc """
  iex> "Hello, " <>
  ...>   "World!"
"""
```

## Known limitations

### Double-escaped quotes

This plugin cannot handle doctests with double-escaped quotes like this:

```elixir
@doc """
iex> "\\""
~S(")
"""
```

The above is a valid doctest, but this plugin is unable to parse it into an AST and then correctly back into a string. Such cases will produce logger warnings.

You can ignore the warnings and accept that this doctests won't be formatted, or you can try the below workaround.

The workaround is to rewrite the whole `@doc`/`@moduledoc` attribute using the `sigil_S`, which does not allow escape characters. This doctest will work exactly the same as the one above, and it will get formatted by this plugin:

```elixir
@doc ~S"""
iex> "\""
~S(")
"""
```

### Dynamic value

This plugin will only format string literals and `s`/`S` sigil literal values of `@doc`/`@moduledoc`. It will not format strings with interpolation or other dynamic values. For example:

```elixir
# will not be formatted:
@moduledoc """
A prank calculator by #{author_name}. Always gives the wrong answer.

iex> PrankCalculator.add(2,2)
5
"""

# will also not be formatted:
@intermediate_module_attr "iex> PrankCalculator.add(2,2)\n5"
@doc @intermediate_module_attr
```

### Formatting conflicts

This plugin needs to parse the whole `.ex` file into an AST and back into a string in order to be able to update the values of `@moduledoc` and `@doc`. When changing the AST back to the string, the code inevitably has to be formatted. Your formatter options are used in this process, so it shouldn't make any changes that the base Elixir formatter wouldn't, but it might conflict with other plugins that modify Elixir code too.
