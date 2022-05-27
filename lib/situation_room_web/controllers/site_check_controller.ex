defmodule SituationRoomWeb.SiteCheckController do
  use SituationRoomWeb, :controller
  alias SituationRoom.Site.Check

  def check(conn, _params) do
    conn
    |> json(Check.get_all_checks())
  end
end
