defmodule SituationRoom.Site.Controller do
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
    send_resp(
      conn,
      200,
      "[#{for content <- Site.get_all_sites(), do: "#{build_site_resp(content)}, "}]"
    )
  end

  # Get a site by id
  get "/:id" do
    if not is_integer(conn.params["id"]) do
      send_resp(conn, 400, "{'error': 'Expected id to be of type integer'}")
    end

    get_site_by(conn, id: conn.params["id"])
  end

  # This route can be hit when forward slashes are encoded as %2F
  post "/" do
    case Site.create_site(conn.params["name"], conn.params["endpoint"]) do
      {:ok, content} ->
        send_resp(conn, 201, build_site_resp(content))

      # We need to pattern match errors for invalid URL
      {:error,
       %Ecto.Changeset{
         action: nil,
         changes: %{},
         errors: [endpoint: errors],
         data: _,
         valid?: false
       }} ->
        send_resp(conn, 400, "{'error': '#{elem(errors, 0)}'}")

      _ ->
        send_resp(conn, 400, "{'error': 'Unable to create #{conn.params["endpoint"]}'}")
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  delete "/:id" do
    case Site.delete_site(id: conn.params["id"]) do
      {:ok, content} ->
        send_resp(conn, 201, build_site_resp(content))

      _ ->
        send_resp(conn, 400, "{'error': 'Unable to delete #{conn.params["id"]}'}")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp get_site_by(conn, field) do
    case Site.get_site(field) do
      res = %SituationRoom.Site{} ->
        send_resp(conn, 200, build_site_resp(res))

      _ ->
        send_resp(
          conn,
          400,
          "{'error': 'Site #{elem(List.first(field), 1)} was not be found..'}"
        )
    end
  end

  defp build_site_resp(content) do
    "{'name': '#{content.name}', 'endpoint': '#{content.endpoint}', 'id': '#{content.id}'}"
  end
end
