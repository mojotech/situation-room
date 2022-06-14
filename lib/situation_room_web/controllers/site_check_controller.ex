defmodule SituationRoomWeb.SiteCheckController do
  use SituationRoomWeb, :controller
  alias SituationRoom.{Checks, Outages, Sites}
  alias SituationRoom.Check.Manager

  def check(conn, _params) do
    conn
    |> json(Checks.get_all_checks())
  end

  def edit(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    Manager.head_check(site)

    case Outages.get_last(id) do
      %SituationRoom.Site.Outage{resolved: result} ->
        case result do
          true ->
            conn |> render("edit.html", site: site, check: "resolved")

          false ->
            conn |> render("edit.html", site: site, check: "down")
        end

      nil ->
        conn |> render("edit.html", site: site, check: "okay")
    end
  end
end
