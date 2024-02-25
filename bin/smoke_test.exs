IO.puts("Running smoke tests")
IO.puts("\n\n")

{diff, 0} = System.cmd("git", ["diff"])

if diff != "" do
  IO.puts(
    "There are unstaged changes. Stage them (git add) or remove them for this check to be able to work."
  )

  System.halt(1)
end

{elixir_version, _} = System.cmd("elixir", ["--version"])

[_, major_version, minor_version, _patch_version] =
  Regex.run(~r/Elixir (\d+)\.(\d+)\.(\d+) \(compiled with/, elixir_version)

major_version = String.to_integer(major_version)
minor_version = String.to_integer(minor_version)

projects =
  [
    "project_with_formatted_code",
    "project_with_unformatted_code"
  ]

Enum.each(projects, fn project ->
  project_path =
    cond do
      # Elixir 1.13 has separate test data because of significantly different formatting defaults
      major_version == 1 && minor_version <= 13 ->
        "smoke_test_data/elixir-1-13/#{project}"

      true ->
        "smoke_test_data/#{project}"
    end

  IO.puts("checking smoke_test_data/#{project}")

  if major_version == 1 && minor_version <= 13 do
    {_, 0} = System.cmd("mix", ["compile"], cd: project_path)
  end

  {_, 0} = System.cmd("mix", ["format"], cd: project_path)
  {diff, 0} = System.cmd("git", ["diff"], cd: project_path)

  Code.eval_file("#{project_path}/expected_diff.ex")

  expected_diff = ExpectedDiff.diff()

  :code.delete(ExpectedDiff)
  :code.purge(ExpectedDiff)

  {"", 0} =
    System.cmd("git", ["checkout", "--", "."], cd: project_path)

  if diff == expected_diff do
    IO.puts("OK")
  else
    IO.puts(
      "Expected #{project} to have specific changes after running `mix format` in it (see `bin/smoke_test.exs`), the actual changes differ. Here's the myers difference between the actual and expected changes:"
    )

    IO.inspect(String.myers_difference(diff, expected_diff))

    System.halt(2)
  end
end)
