defmodule SituationRoomWeb.ControllerCheckTest do
  use SituationRoomWeb.ConnCase, async: true
  use ExUnit.Case, async: false

  alias SituationRoom.Site

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)

    %{site: seed()}
  end

  test "test GET all site pings", %{conn: conn, site: site} do
    response =
      conn
      |> get(Routes.site_check_path(conn, :check, site.id))

    assert response.state == :sent
    assert response.status == 200
  end

  defp seed do
    {:ok, site} = Site.create_site(%{"name" => "testName", "endpoint" => "https://test.com"})

    site
  end
end
