defmodule SituationRoom.InsertTest do
  use ExUnit.Case
  import SituationRoom.Site

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
  end

  @test_suites [
    {"MojoTech Main", "https://mojotech.com", true},
    {"MojoTech API", "http://api.mojotech.com", true},
    {"x", "https://x.com", true},
    {"Flop", "pets.com", false},
    {"", "https://google.com", false},
    {"Nope", "F.", false},
    {"Davo", "", false},
    {"Uni", "U", false}
  ]

  for i <- @test_suites do
    mac = Macro.escape(i)

    test "Return valid validation for #{elem(i, 1)}" do
      test_case = unquote(mac)
      expected_result = elem(test_case, 2)
      res = create_site(elem(test_case, 0), elem(test_case, 1))

      if expected_result do
        assert {:ok, _} = res
      else
        assert {:error, _} = res
      end
    end
  end
end
