defmodule SituationRoom.Site do
  @moduledoc """
  Documentation for `SituationRoom.Site`.
  """
  use Ecto.Schema
  import Ecto.Changeset
  import SituationRoom.Repo

  schema "sites" do
    field(:endpoint, :string)
    field(:name, :string)
  end

  # Delete a site from the database by specifying specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def delete_site(param) do
    case res = get_site(param) do
      %SituationRoom.Site{} ->
        delete(res)

      _ ->
        {:error, "Site does not exist"}
    end

    # Rescues when there is an unexpected error.. eg. duplicate entries found in db
  rescue
    _ -> {:error, "Cannot delete site"}
  end

  # Get a site from the database by one specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def get_site(param) do
    SituationRoom.Site |> get_by(param)
  end

  # Returns all sites in the database
  def get_all_sites() do
    SituationRoom.Site |> all
  end

  # Creates a site in the database by taking two String.t() params
  # param ex: ("mojo", "http://mojotech.com")
  @spec create_site(String.t(), String.t()) :: {:ok, Site.t()} | {:error, Site.t()}
  def create_site(name, endpoint) do
    changeset = changeset(%SituationRoom.Site{}, %{"name" => name, "endpoint" => endpoint})

    if changeset.valid? do
      insert(changeset, on_conflict: :nothing)
    else
      {:error, changeset}
    end
  end

  # Default changeset to be used to validate against schema
  def changeset(site, params) do
    site
    |> cast(params, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
    # Should we split this up to validate scheme, host, and valid endpoint?
    |> validate_endpoint(:endpoint)
  end

  # Function to test if a url is valid and returns why it is not valid
  def validate_endpoint(changeset, field, opts \\ []) do
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
