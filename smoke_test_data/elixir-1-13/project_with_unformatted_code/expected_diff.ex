defmodule ExpectedDiff do
  def diff do
    """
    diff --git a/smoke_test_data/elixir-1-13/project_with_unformatted_code/README.md b/smoke_test_data/elixir-1-13/project_with_unformatted_code/README.md
    index d066e9b..0ccfa0b 100644
    --- a/smoke_test_data/elixir-1-13/project_with_unformatted_code/README.md
    +++ b/smoke_test_data/elixir-1-13/project_with_unformatted_code/README.md
    @@ -9,9 +9,9 @@ by adding `project_with_unformatted_code` to your list of dependencies in `mix.e
    #{" "}
     ```elixir
     def deps do
    -[
    -{ :project_with_unformatted_code, "~> 0.1.0" }
    -]
    +  [
    +    {:project_with_unformatted_code, "~> 0.1.0"}
    +  ]
     end
     ```
    #{" "}
    diff --git a/smoke_test_data/elixir-1-13/project_with_unformatted_code/docs/hello.md b/smoke_test_data/elixir-1-13/project_with_unformatted_code/docs/hello.md
    index 114bb32..8d4ffe5 100644
    --- a/smoke_test_data/elixir-1-13/project_with_unformatted_code/docs/hello.md
    +++ b/smoke_test_data/elixir-1-13/project_with_unformatted_code/docs/hello.md
    @@ -1,7 +1,7 @@
     # Hello!
    #{" "}
     ~~~~elixir
    -%{ x: 7,   y: 8}
    +%{x: 7, y: 8}
     ~~~~
    #{" "}
     [//]: # (elixir-formatter-disable-next-block)
    @@ -11,7 +11,7 @@
     ~~~~
    #{" "}
     ```elixir
    -%{ x: 7,   y: 8}
    +%{x: 7, y: 8}
     ```
    #{" "}
     ```markdown
    """
  end
end
