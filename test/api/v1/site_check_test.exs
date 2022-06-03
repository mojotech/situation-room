defmodule SituationRoom.Site.CheckTest do
  use ExUnit.Case, async: true
  alias SituationRoom.Site.Check

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
    %{site: seed()}
  end

  @test_suites [
    {200, 3.2345, true},
    {302, 100, true},
    {404, 1000, true},
    {"Nope", 234, false},
    {200, "Nope", false},
    {"200", "200", true}
  ]

  for i <- @test_suites do
    mac = Macro.escape(i)

    test "Return validation for #{elem(i, 0)} - #{elem(i, 1)}", %{site: site} do
      test_case = unquote(mac)

      result =
        Check.changeset(%Check{}, %{
          "site_id" => site.id,
          "status_code" => elem(test_case, 0),
          "response_time" => elem(test_case, 1)
        })

      assert result.valid? == elem(test_case, 2)
    end

    test "Test site creation and query for #{elem(i, 0)} - #{elem(i, 1)}", %{site: site} do
      test_case = unquote(mac)
      expected_result = elem(test_case, 2)

      create_res =
        Check.create_check(%{
          "site_id" => site.id,
          "status_code" => elem(test_case, 0),
          "response_time" => elem(test_case, 1)
        })

      if expected_result do
        assert {:ok, _res} = create_res
      else
        assert {:error, _} = create_res
      end
    end
  end

  defp seed do
    {:ok, site} =
      SituationRoom.Site.create_site(%{
        "name" => "TestSite",
        "endpoint" => "https://test.com",
        "interval" => 60
      })

    site
  end
end
