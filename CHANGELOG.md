# Changelog

## Unreleased

- Support opaque types in doctest results (e.g. `#User<name: "", ...>`).

## 0.2.1 (2024-03-22)

- Do not crash if doctest has no expected result.

## 0.2.0 (2024-02-27)

- Support parsing multiline doctests with `iex>` on all lines, but reformat them using `...>` on every line but the first one.
- Fix implementation for multiline results. Multiline results are allowed, and they can be terminated with an empty new line or another doctest.
- Support exception expressions (`** (ModuleName) message`) in results.
- Desired line length for doctest result now accounts for its indentation.
- Support doctests with iex prompts with a line number, e.g.: `iex(1)>`.

## 0.1.0 (2024-02-25)

- Initial release.
