defmodule SituationRoom.Sites do
  @moduledoc """
  Common repository methods for Sites
  """

  alias SituationRoom.Repo
  alias SituationRoom.Site

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
  end

  # Delete a site from the database by specifying specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def delete_site(site) do
    Repo.delete(site)
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end
end
