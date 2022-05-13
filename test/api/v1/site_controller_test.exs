defmodule SituationRoom.Site.ControllerTest do
  import Jason, only: [encode!: 2, decode: 2]
  use ExUnit.Case, async: false
  use Plug.Test
  alias SituationRoom.Router
  alias SituationRoom.Site

  @opts Router.init([])

  @test_site {"testName", "https://test.com", "https:%2F%2Ftest.com"}
  @test_name elem(@test_site, 0)
  @test_url elem(@test_site, 1)
  @test_url_http elem(@test_site, 2)

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
    seed
  end

  describe "test CRUD methods" do
    test "test POST site", state do
      conn = conn(:post, "/sites", %{"name" => @test_name, "endpoint" => @test_url})
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 201

      assert {:ok, conn.resp_body} ==
               Jason.encode(%{name: @test_name, endpoint: @test_url, id: state[:insert_id] + 1})
    end

    test "test DEL site", state do
      conn = conn(:delete, "/sites/#{state[:insert_id]}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 204
    end

    test "invalid test POST site - invalid host" do
      conn = conn(:post, "/sites?name=#{@test_name}&endpoint=#{@test_url_http}badhost")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "invalid host"
    end

    test "invalid test POST site - cant be blank" do
      conn = conn(:post, "/sites", %{"name" => @test_name, "endpoint" => ""})
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "can't be blank"
    end

    test "invalid test POST site - missing scheme" do
      conn = conn(:post, "/sites", %{"name" => @test_name, "endpoint" => @test_name})
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "is missing a scheme (e.g. https)"
    end

    test "invalid test GET site - does not exist" do
      conn = conn(:get, "/sites/345324562")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "Not Found"
    end

    test "invalid test DEL site - nonexistant id" do
      conn = conn(:delete, "/sites/a")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 404
      assert conn.resp_body == "Not Found"
    end
  end

  defp seed do
    {:ok, res} = Site.create_site(@test_name, @test_url)
    {:ok, insert_id: res.id}
  end
end
