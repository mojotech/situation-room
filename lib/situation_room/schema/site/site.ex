defmodule SituationRoom.Site do
  @moduledoc """
  Documentation for `SituationRoom.Site`.
  """
  use Ecto.Schema
  import Ecto.Changeset

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
