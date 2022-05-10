defmodule SituationRoom.Router do
  import Plug.Conn
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/ping" do
    send_resp(conn, 200, "Mojo Pong")
  end

  match _ do
    send_resp(conn, 404, "We couldn't find 'er :(")
  end

end
