defmodule SituationRoom.SiteTest do
  use ExUnit.Case, async: true
  alias SituationRoom.Site

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
  end

  @test_suites [
    {"MojoTech Main", "https://youtube.com", true},
    {"MojoTech API", "http://mail.google.com", true},
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

      result =
        Site.changeset(%Site{}, %{
          "name" => elem(test_case, 0),
          "endpoint" => elem(test_case, 1)
        })

      assert result.valid? == elem(test_case, 2)
    end

    test "Test site creation, query, and deletion #{elem(i, 1)}" do
      test_case = unquote(mac)
      expected_result = elem(test_case, 2)

      create_res =
        Site.create_site(%{"name" => elem(test_case, 0), "endpoint" => elem(test_case, 1)})

      if expected_result do
        assert {:ok, res} = create_res

        assert {:ok, _} = Site.delete_site("#{res.id}")
      else
        assert {:error, _} = create_res
      end
    end
  end
end