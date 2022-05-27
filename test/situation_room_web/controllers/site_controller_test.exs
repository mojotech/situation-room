defmodule SituationRoom.Site.ControllerTest do
  use SituationRoomWeb.ConnCase, async: true
  use ExUnit.Case, async: false

  alias SituationRoom.Site

  @test_site {"testName", "https://test.com", "https:%2F%2Ftest.com"}
  @test_name elem(@test_site, 0)
  @test_url elem(@test_site, 1)
  @test_url_http elem(@test_site, 2)

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
    %{site: seed()}
  end

  describe "test CRUD methods" do
    test "test POST site", %{conn: conn, site: site} do
      response =
        conn
        |> post(
          Routes.site_path(conn, :create),
          %{"name" => @test_name, "endpoint" => @test_url}
        )
        |> json_response(201)

      assert site.id + 1 == response["id"]
    end

    test "test DEL site", %{conn: conn, site: site} do
      conn
      |> delete(Routes.site_path(conn, :delete, site.id))
      |> json_response(204)
    end

    test "invalid test POST site", %{conn: conn} do
      conn
      |> post(
        Routes.site_path(conn, :create),
        %{
          "name" => @test_name,
          "endpoint" => "#{@test_url_http}badhost"
        }
      )
      |> json_response(400)
    end

    test "invalid test GET site - does not exist", %{conn: conn} do
      conn
      |> get(Routes.site_path(conn, :show, 9_999_324_562))
      |> json_response(404)
    end

    test "invalid test DEL site - nonexistant id", %{conn: conn} do
      conn
      |> delete(Routes.site_path(conn, :delete, 9_915_809))
      |> json_response(404)
    end
  end

  defp seed do
    {:ok, site} = Site.create_site(%{"name" => @test_name, "endpoint" => @test_url})

    site
  end
end
