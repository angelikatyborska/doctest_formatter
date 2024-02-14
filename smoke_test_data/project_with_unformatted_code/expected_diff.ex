defmodule ExpectedDiff do
  def diff do
    """
    diff --git a/smoke_test_data/project_with_unformatted_code/README.md b/smoke_test_data/project_with_unformatted_code/README.md
    index d066e9b..0ccfa0b 100644
    --- a/smoke_test_data/project_with_unformatted_code/README.md
    +++ b/smoke_test_data/project_with_unformatted_code/README.md
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
    diff --git a/smoke_test_data/project_with_unformatted_code/docs/hello.md b/smoke_test_data/project_with_unformatted_code/docs/hello.md
    index 114bb32..8d4ffe5 100644
    --- a/smoke_test_data/project_with_unformatted_code/docs/hello.md
    +++ b/smoke_test_data/project_with_unformatted_code/docs/hello.md
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
    diff --git a/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex b/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    index 7af383c..c94df7f 100644
    --- a/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    +++ b/smoke_test_data/project_with_unformatted_code/lib/project_with_unformatted_code.ex
    @@ -17,13 +17,14 @@ defmodule ProjectWithUnformattedCode do
         # Hello, World!
    #{" "}
         ```elixir
    -    def add(a,b), do: a+b
    +    def add(a, b), do: a + b
         ```
    #{" "}
         ```js
         1+2+3
         ```
         \"""
    +
         :world
       end
     end
    """
  end
end
