defmodule SituationRoom.Site.Controller do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  import Jason, only: [encode!: 2]
  alias SituationRoom.Site
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["text/*"]
  )

  plug(:dispatch)

  # Get all sites
  get "/" do
    sites = Site.get_all_sites()

    send_resp(
      conn,
      200,
      Jason.encode!(sites)
    )
  end

  # Get a site by id
  get "/:id" do
    case Site.get_site(id: conn.params["id"]) do
      {:ok, content} ->
        send_resp(conn, 200, Jason.encode!(content))

      {:error, message} ->
        send_resp(conn, 404, message)
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  post "/" do
    case Site.create_site(conn.params["name"], conn.params["endpoint"]) do
      {:ok, content} ->
        send_resp(conn, 201, Jason.encode!(content))

      {:error, message} ->
        send_resp(conn, 400, message)
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  delete "/:id" do
    case Site.delete_site(id: conn.params["id"]) do
      {:ok, content} ->
        send_resp(conn, 200, Jason.encode!(content))

      {:error, message} ->
        send_resp(conn, 404, message)
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
