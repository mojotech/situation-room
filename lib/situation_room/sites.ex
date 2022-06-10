defmodule SituationRoom.Sites do
  @moduledoc """
  Common repository methods for Sites
  """

  alias SituationRoom.Repo
  alias SituationRoom.Site

  @topic "sites"

  # Get a site from the database by one specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def get_site(param) do
    Repo.get_by(Site, param)
  end

  def get_site!(id), do: Repo.get!(Site, id)

  # Returns all sites in the database
  def get_all_sites() do
    Repo.all(Site)
  end

  # Creates a site in the database by taking two String.t() params
  # param ex: ("mojo", "http://mojotech.com")
  def create_site(params) do
    %Site{}
    |> Site.changeset(params)
    |> Repo.insert()
    |> broadcast(:site_created)
  end

  # Delete a site from the database by specifying specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def delete_site(site) do
    Repo.delete(site)
    |> broadcast(:site_deleted)
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
    |> broadcast(:site_updated)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(SituationRoom.PubSub, @topic)
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, site}, event) do
    Phoenix.PubSub.broadcast(SituationRoom.PubSub, @topic, {event, site})
    {:ok, site}
  end
end
