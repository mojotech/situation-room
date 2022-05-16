defmodule SituationRoom.Site do
  @moduledoc """
  Documentation for `SituationRoom.Site`.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias SituationRoom.Repo

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
    case Repo.get_by(SituationRoom.Site, param) do
      {:ok, content} ->
        {:ok, build_site_resp(content)}

      _ ->
        {:error, "Not Found"}
    end
  end

  # Returns all sites in the database
  def get_all_sites() do
    "[#{for content <- Repo.all(SituationRoom.Site), do: "#{build_site_resp(content)}, "}]"
  end

  # Creates a site in the database by taking two String.t() params
  # param ex: ("mojo", "http://mojotech.com")
  @spec create_site(String.t(), String.t()) :: {:ok, Site.t()} | {:error, Site.t()}
  def create_site(name, endpoint) do
    case Repo.insert(changeset(%SituationRoom.Site{}, %{"name" => name, "endpoint" => endpoint}),
           on_conflict: :nothing
         ) do
      {:ok, content} ->
        {:ok, build_site_resp(content)}

      # We need to pattern match errors for invalid URL
      {:error,
       %Ecto.Changeset{
         action: nil,
         changes: %{},
         errors: [endpoint: errors],
         data: _,
         valid?: false
       }} ->
        {:error, "#{elem(errors, 0)}"}

      _ ->
        {:error, "Unable to create site"}
    end
  end

  # Delete a site from the database by specifying specific field
  # param ex: (name: "mojotech") or (endpoint: "http://mojo.com")
  def delete_site(param) do
    case res = Repo.get_by(SituationRoom.Site, param) do
      %SituationRoom.Site{} ->
        {:ok, content} = Repo.delete(res)
        {:ok, build_site_resp(content)}

      _ ->
        {:error, "Not Found"}
    end
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

  defp build_site_resp(content) do
    "{'name': '#{content.name}', 'endpoint': '#{content.endpoint}', 'id': '#{content.id}'}"
  end
end
