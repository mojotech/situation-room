defmodule SituationRoom.Site do
  @moduledoc """
  Documentation for `SituationRoom.Site`.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SituationRoom.Repo

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "sites" do
    field(:endpoint, :string)
    field(:name, :string)
  end

  # Default changeset to be used to validate against schema
  def changeset(site, params) do
    site
    |> cast(params, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
    |> validate_endpoint(:endpoint)
  end

  # Get a site from the database by one specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def get_site(param) do
    Repo.get_by(SituationRoom.Site, param)
  end

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
  @spec delete_site(String.t()) :: any
  def delete_site(id) do
    Repo.delete(%SituationRoom.Site{id: String.to_integer(id)})
  rescue
    Ecto.StaleEntryError ->
      {:error, :not_found}

    _ ->
      {:error, :unknown}
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
