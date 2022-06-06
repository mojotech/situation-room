defmodule SituationRoomWeb.SiteCheckController do
  use SituationRoomWeb, :controller
  alias SituationRoom.Checks

  def check(conn, _params) do
    conn
    |> json(Checks.get_all_checks())
  end
end
