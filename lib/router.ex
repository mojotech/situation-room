defmodule SituationRoom.Router do
  use Plug.Router

  if Mix.env() == :dev do
    use Plug.Debugger
  end

  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(:match)
  # If we are going to include plug.Parsers, they go right here
  plug(:dispatch)

  get("/", do: send_resp(conn, 204, ""))
  get("/ping", do: send_resp(conn, 204, ""))
  get("/status", do: send_resp(conn, 204, ""))

  forward("/sites", to: SituationRoom.Site.Controller)

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
