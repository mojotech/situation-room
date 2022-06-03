defmodule SituationRoom.Site do
  @moduledoc """
  Documentation for `SituationRoom.Site`.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SituationRoom.Repo

  @derive {Jason.Encoder, except: [:__meta__, :site_checks, :site_notifications]}
  schema "sites" do
    field(:endpoint, :string)
    field(:name, :string)
    field(:interval, :integer, default: 300, null: false)
    has_many(:site_checks, SituationRoom.Site.Check)
    has_many(:site_notifications, SituationRoom.Site.Notification)

    timestamps()
  end

  # Default changeset to be used to validate against schema
  def changeset(site, params \\ %{}) do
    site
    |> cast(params, [:endpoint, :name, :interval])
    |> validate_required([:endpoint, :name, :interval])
    |> validate_endpoint(:endpoint)
  end

  # Get a site from the database by one specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def get_site(param) do
    Repo.get_by(SituationRoom.Site, param)
  end

  def get_site!(id), do: Repo.get!(SituationRoom.Site, id)

  # Returns all sites in the database
  def get_all_sites() do
    Repo.all(SituationRoom.Site)
  end

  # Creates a site in the database by taking two String.t() params
  # param ex: ("mojo", "http://mojotech.com")
  def create_site(params) do
    %SituationRoom.Site{}
    |> changeset(params)
    |> Repo.insert()
  end

  # Delete a site from the database by specifying specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def delete_site(site) do
    Repo.delete(site)
  end

  def update_site(%__MODULE__{} = site, attrs) do
    site
    |> changeset(attrs)
    |> Repo.update()
  end

  # Function to test if a url is valid and returns why it is not valid
  defp validate_endpoint(changeset, field, opts \\ []) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} ->
          "is missing a scheme (e.g. https)"

        %URI{host: nil} ->
          "is missing a host"

        %URI{host: host} ->
          determine_valid_url(host)
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end)
  end

  defp determine_valid_url(host) do
    case :inet.gethostbyname(Kernel.to_charlist(host)) do
      {:ok, _} -> nil
      {:error, _} -> "invalid host"
    end
  end
end
