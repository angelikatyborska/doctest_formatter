# Doctest Formatter

![GitHub Workflow status](https://github.com/angelikatyborska/doctest_formatter/actions/workflows/test.yml/badge.svg)
![version on Hex.pm](https://img.shields.io/hexpm/v/doctest_formatter)
![number of downloads on Hex.pm](https://img.shields.io/hexpm/dt/doctest_formatter)
![license on Hex.pm](https://img.shields.io/hexpm/l/doctest_formatter)

An Elixir formatter for Elixir code in doctests.

It will **not** format any other part of your documentation.

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

Elixir 1.13.2 or up is required. Versions lower than 1.13 do not support formatter plugins, and versions 1.13.0 and 1.13.1 do not support formatter plugins for `.iex` files.

## Usage

Run `mix format`.
