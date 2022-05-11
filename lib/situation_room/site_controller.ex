defmodule SituationRoom.Site.Controller do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  alias SituationRoom.Site
  use Plug.Router

  plug(:match)
  # If we are going to include plug.Parsers, they go right here
  plug(:dispatch)

  # Get a site by name
  get "/name/:name" do
    get_site_by(conn, name: conn.params["name"])
  end

  # Get a site by endpoint/url
  get "/endpoint/:endpoint" do
    get_site_by(conn, endpoint: conn.params["endpoint"])
  end

  # Get a site by id
  get "/id/:id" do
    get_site_by(conn, id: conn.params["id"])
  end

  # This route can be hit when forward slashes are encoded as %2F
  post "/:name/:endpoint" do
    case res = Site.create_site(conn.params["name"], conn.params["endpoint"]) do
      {:ok, _} ->
        send_resp(conn, 201, "{:ok, 'Successfully created #{conn.params["endpoint"]}'}")

      # We need to pattern match errors for invalid URL
      {:error,
       %Ecto.Changeset{
         action: nil,
         changes: %{},
         errors: [endpoint: errors],
         data: _,
         valid?: false
       }} ->
        send_resp(conn, 400, "{:error, '#{elem(errors, 0)}'}")

      _ ->
        send_resp(conn, 400, "{:error, 'Unable to create #{conn.params["endpoint"]}'}")
    end
  end

  # This route can be hit when forward slashes are encoded as %2F
  delete "/:endpoint" do
    case Site.delete_site(endpoint: conn.params["endpoint"]) do
      {:ok, _} ->
        send_resp(conn, 201, "{:ok, '#{conn.params["endpoint"]} has been deleted'}")

      _ ->
        send_resp(conn, 400, "{:error, 'Unable to delete #{conn.params["endpoint"]}'}")
    end
  end

  match _ do
    send_resp(conn, 404, "We couldn't find the specified site route.. ")
  end

  defp get_site_by(conn, field) do
    case res = Site.get_site(field) do
      %SituationRoom.Site{} = res ->
        send_resp(
          conn,
          200,
          "{:ok, {'name': #{Map.get(res, :name)}, 'endpoint': '#{Map.get(res, :endpoint)}', 'id': '#{Map.get(res, :id)}'}}"
        )

      _ ->
        send_resp(
          conn,
          400,
          "{:error, '#{elem(List.first(field), 1)} was not be found.. Please make sure everything is entered correctly.'}"
        )
    end
  end
end
