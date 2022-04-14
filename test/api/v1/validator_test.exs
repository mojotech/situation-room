defmodule API.ValidatorTest do
  use ExUnit.Case

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
      result = SituationRoom.Site.changeset(%SituationRoom.Site{}, %{"name" => elem(test_case, 0), "endpoint" => elem(test_case, 1)})
      assert result.valid? == elem(test_case, 2)
    end
  end
end
