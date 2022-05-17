defmodule SituationRoom.Site.Check.Controller do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  use Plug.Router
  alias SituationRoom.Site.Check

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(
      conn,
      200,
      Jason.encode!(Check.get_all_checks())
    )
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
