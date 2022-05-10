defmodule SituationRoom.Router do
  use Plug.Router
  alias SituationRoom.Site

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(:match)
  # If we are going to include plug.Parsers, they go right here
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "Mojo Pong")
  end

  # get "site" do
  #   Site.get_all_sites()
  #   |> clean_query()
  #   |> case do
  #     {:ok, content} ->
  #       send_resp(conn, 200, "[]")
  #     _ ->
  #       send_resp(conn, 500, "Unable to get sites")
  #   end
  # end

  # This route can be hit when forward slashes are encoded as %2F
  post "/site/:name/:endpoint" do
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
  delete "/site/:endpoint" do
    case Site.delete_site(endpoint: conn.params["endpoint"]) do
      {:ok, _} ->
        send_resp(conn, 201, "{:ok, '#{conn.params["endpoint"]} has been deleted'}")

      _ ->
        IO.inspect("Pattern matched catch all")
        send_resp(conn, 400, "{:error, 'Unable to delete #{conn.params["endpoint"]}'}")
    end
  end

  match _ do
    send_resp(conn, 404, "We couldn't find 'er :(")
  end
end
