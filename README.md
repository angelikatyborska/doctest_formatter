# Doctest Formatter

![GitHub Workflow status](https://github.com/angelikatyborska/doctest_formatter/actions/workflows/test.yml/badge.svg)
![version on Hex.pm](https://img.shields.io/hexpm/v/doctest_formatter)
![number of downloads on Hex.pm](https://img.shields.io/hexpm/dt/doctest_formatter)
![license on Hex.pm](https://img.shields.io/hexpm/l/doctest_formatter)

An Elixir formatter for Elixir code in doctests.

![Running mix format formats your Elixir code in doctests](https://raw.github.com/angelikatyborska/doctest_formatter/main/assets/mix-format.gif)

## Installation

The package can be installed by adding `doctest_formatter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:doctest_formatter, "~> 0.1.0", runtime: false}
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

## Known limitations

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
