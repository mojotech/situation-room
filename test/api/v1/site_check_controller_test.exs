defmodule SituationRoom.Site.Check.ControllerTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias SituationRoom.Router
  alias SituationRoom.Site

  @opts Router.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
    seed
  end

  describe "test CRUD methods" do
    test "test GET all site pings", state do
      conn = conn(:get, "/sites/#{state[:insert_id]}/checks")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 200
    end
  end

  defp seed do
    {:ok, res} = Site.create_site(%{"name" => "testName", "endpoint" => "https://test.com"})
    {:ok, insert_id: res.id}
  end
end
