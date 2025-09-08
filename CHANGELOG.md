# Changelog

## 0.4.1 (2025-09-08)

- Stop adding a trailing space to empty `iex>` lines.

## 0.4.0 (2025-05-09)

- Stop adding a trailing space to empty `iex>` lines.

## 0.3.1 (2024-11-24)

- Respect `line_length` option when formatting the whole `.ex` file. 

## 0.3.0 (2024-04-01)

- Support opaque types in doctest results (e.g. `#User<name: "", ...>`).
- Do not crash when doctests contain double-escaped quotes. Instead, print a warning and leave the code snippet unformatted.

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
