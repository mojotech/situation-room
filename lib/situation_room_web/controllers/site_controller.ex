defmodule SituationRoomWeb.SiteController do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  use SituationRoomWeb, :controller

  alias SituationRoom.Site
  alias SituationRoom.Sites

  # Get all sites
  def index(conn, _params) do
    conn
    |> render("index.html", sites: Sites.get_all_sites())
  end

  def show(conn, %{"id" => id}) do
    case Sites.get_site(%{id: id}) do
      %SituationRoom.Site{} = site ->
        conn
        |> render("show.html", site: site)

      nil ->
        conn
        |> put_status(404)
        |> json(%{error: "Not Found"})
    end
  end

  def new(conn, _params) do
    changeset = Site.changeset(%Site{})

    conn
    |> render("new.html", changeset: changeset)
  end

  def create(conn, %{"site" => site_params}) do
    case Sites.create_site(site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site created successfully.")
        |> redirect(to: Routes.site_path(conn, :show, site))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    changeset = Site.changeset(site)

    conn
    |> render("edit.html", site: site, changeset: changeset)
  end

  def update(conn, %{"id" => id, "site" => site_params}) do
    site = Sites.get_site!(id)

    case Sites.update_site(site, site_params) do
      {:ok, site} ->
        conn
        |> put_flash(:info, "Site updated successfully.")
        |> redirect(to: Routes.site_path(conn, :show, site))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", site: site, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    {:ok, _site} = Sites.delete_site(site)

    conn
    |> put_flash(:info, "Site deleted successfully.")
    |> redirect(to: Routes.site_path(conn, :index))
  end
end
