defmodule SituationRoom.Site.ControllerTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias Ecto.Adapters.SQL.Sandbox
  alias SituationRoom.{Router, Site}

  @opts Router.init([])
  @test_site {"testName", "https://test.com", "https:%2F%2Ftest.com", "https://test.asdfg",
              "https:%2F%2Ftest.asdfg"}
  @test_name elem(@test_site, 0)
  @test_url elem(@test_site, 1)
  @test_url_http elem(@test_site, 2)
  @test_url_invalid elem(@test_site, 3)
  @test_url_invalid_http elem(@test_site, 4)

  setup do
    :ok = Sandbox.checkout(SituationRoom.Repo)
    seed()
  end

  describe "test CRUD methods" do
    test "test POST site" do
      conn = conn(:post, "/site/#{@test_name}/#{@test_url_http}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 201
      assert conn.resp_body == "{:ok, 'Successfully created #{@test_url}'}"
    end

    test "test GET site by name" do
      conn = conn(:get, "/site/name/#{@test_name}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 200

      assert String.starts_with?(
               conn.resp_body,
               "{:ok, {'name': #{@test_name}, 'endpoint': '#{@test_url}', 'id': "
             )
    end

    test "test GET site by endpoint" do
      conn = conn(:get, "/site/endpoint/#{@test_url_http}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 200

      assert String.starts_with?(
               conn.resp_body,
               "{:ok, {'name': #{@test_name}, 'endpoint': '#{@test_url}', 'id': "
             )
    end

    test "test DEL site" do
      conn = conn(:delete, "/site/#{@test_url_http}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 201
      assert conn.resp_body == "{:ok, '#{@test_url} has been deleted'}"
    end

    test "invalid test POST site - not url encoded //" do
      conn = conn(:post, "/site/#{@test_name}/#{@test_url}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 404
    end

    test "invalid test POST site - invalid host" do
      conn = conn(:post, "/site/#{@test_name}/#{@test_url_invalid_http}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "{:error, 'invalid host'}"
    end

    test "invalid test POST site - missing scheme" do
      conn = conn(:post, "/site/#{@test_name}/#{@test_name}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "{:error, 'is missing a scheme (e.g. https)'}"
    end

    test "invalid test GET site - does not exist" do
      conn = conn(:get, "/site/name/F#{@test_name}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400

      assert conn.resp_body ==
               "{:error, 'F#{@test_name} was not be found.. Please make sure everything is entered correctly.'}"
    end

    test "invalid test DEL site - nonexistant site" do
      conn = conn(:delete, "/site/#{@test_url_invalid_http}")
      conn = Router.call(conn, @opts)
      assert conn.state == :sent
      assert conn.status == 400
      assert conn.resp_body == "{:error, 'Unable to delete #{@test_url_invalid}'}"
    end
  end

  defp seed do
    case res = Site.get_site(name: @test_name) do
      nil = res ->
        Site.create_site(@test_name, @test_url)
        :ok

      _ ->
        :ok
    end
  end
end
