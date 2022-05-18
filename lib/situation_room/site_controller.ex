defmodule SituationRoom.Site.Controller do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  use Plug.Router
  alias SituationRoom.Site

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart],
    pass: ["text/*"]
  )

  plug(:dispatch)

  # Get all sites
  get "/" do
    send_resp(
      conn,
      200,
      Jason.encode!(Site.get_all_sites())
    )
  end

  # Get a site by id
  get "/:id" do
    case Site.get_site(id: conn.params["id"]) do
      res = %SituationRoom.Site{} ->
        send_resp(conn, 200, Jason.encode!(res))

      nil ->
        send_resp(conn, 404, "")
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  post "/" do
    case Site.create_site(conn.params) do
      {:ok, content} ->
        send_resp(conn, 201, Jason.encode!(content))

      {:error, changeset} ->
        send_resp(
          conn,
          400,
          Jason.encode!(Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end))
        )

      _ ->
        send_resp(conn, 400, "Cannot POST site")
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  delete "/:id" do
    case Site.delete_site(conn.params["id"]) do
      {:ok, _} ->
        send_resp(conn, 204, "")

      {:error, :not_found} ->
        send_resp(conn, 404, "")

      {:error, :unknown} ->
        send_resp(conn, 404, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
