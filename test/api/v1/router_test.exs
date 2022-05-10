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
    assert conn.status == 200
    assert conn.resp_body == "{:ok, Mojo Pong}"
  end

  test "post a site" do
    conn = conn(:post, "/site/testName/https:%2F%2Ftest.com")
    conn = Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "{:ok, 'Successfully created https://test.com'}"
    conn = conn(:delete, "/site/https:%2F%2Ftest.com")
    conn = Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 201
    assert conn.resp_body == "{:ok, 'https://test.com has been deleted'}"
  end
end
