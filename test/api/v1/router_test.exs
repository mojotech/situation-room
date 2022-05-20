defmodule SituationRoom.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias SituationRoom.Router

  @opts Router.init([])

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
  end

  test "return /ping route" do
    conn = conn(:get, "/ping")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
  end

  test "return /status route" do
    conn = conn(:get, "/status")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
  end

  test "return / route" do
    conn = conn(:get, "/")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 204
  end

  test "invalid route" do
    conn = conn(:get, "/invalidRouteZYX")
    conn = Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Not Found"
  end
end
