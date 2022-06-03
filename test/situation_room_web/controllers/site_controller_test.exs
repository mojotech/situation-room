defmodule SituationRoom.Site.ControllerTest do
  use SituationRoomWeb.ConnCase, async: true
  use ExUnit.Case, async: false

  @test_site {"testName", "https://test.com", "https:%2F%2Ftest.com"}
  @test_name elem(@test_site, 0)
  @test_url elem(@test_site, 1)
  @test_interval 60

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
    %{site: seed()}
  end

  describe "test CRUD methods" do
    test "test POST site", %{conn: conn} do
      conn
      |> post(
        Routes.site_path(conn, :create),
        %{
          "site" => %{
            "name" => @test_name,
            "endpoint" => @test_url,
            "interval" => @test_interval
          }
        }
      )
      |> response(302)
    end

    test "test DEL site", %{conn: conn, site: site} do
      conn
      |> delete(Routes.site_path(conn, :delete, site.id))
      |> response(302)
    end

    test "invalid test GET site - does not exist", %{conn: conn} do
      conn
      |> get(Routes.site_path(conn, :show, 9_999_324_562))
      |> json_response(404)
    end

    test "invalid test DEL site - nonexistant id", %{conn: conn} do
      assert_error_sent(:not_found, fn ->
        conn
        |> delete(Routes.site_path(conn, :delete, 9_915_809))
      end)
    end
  end

  defp seed do
    alias SituationRoom.Sites

    {:ok, site} =
      Sites.create_site(%{"name" => @test_name, "endpoint" => @test_url, "interval" => 60})

    site
  end
end
