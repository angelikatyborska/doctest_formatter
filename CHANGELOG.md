# Changelog

## Unreleased

- Support parsing multiline doctests with `iex>` on all lines, but reformat them using `...>` on every line but the first one.
- Fix implementation for multiline results. Multiline results are allowed, and they can be terminated with an empty new line or another doctest.
- Support exception expressions (`** (ModuleName) message`) in results.

## 0.1.0 (2024-02-25)

- Initial release.
