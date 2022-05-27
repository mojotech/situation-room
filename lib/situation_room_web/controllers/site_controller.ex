defmodule SituationRoomWeb.SiteController do
  @moduledoc """
  Documentation for `SituationRoom.Site.Controller`.
  """
  use SituationRoomWeb, :controller

  alias SituationRoom.Site

  # Get all sites
  def index(conn, _params) do
    conn
    |> json(Site.get_all_sites())
  end

  def show(conn, %{"id" => id}) do
    case Site.get_site(%{id: id}) do
      %SituationRoom.Site{} = site ->
        conn
        |> json(site)

      nil ->
        conn
        |> put_status(404)
        |> json(%{error: "Not Found"})
    end
  end

  def create(conn, params) do
    case Site.create_site(params) do
      {:ok, content} ->
        conn
        |> put_status(201)
        |> json(content)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> json(Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end))

      _ ->
        conn
        |> put_status(400)
        |> json(%{error: "Cannot POST site"})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Site.delete_site(id) do
      {:ok, _} ->
        conn
        |> put_status(204)
        |> json(%{error: "No Content"})

      {:error, _} ->
        conn
        |> put_status(404)
        |> json(%{error: "Not found"})
    end
  end
end
