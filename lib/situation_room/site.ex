defmodule SituationRoom.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :endpoint, :string
    field :name, :string
  end

  # Default changeset to be used to validate against schema
  def changeset(site, params) do
    site
    |> cast(params, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
    |> validate_endpoint(:endpoint) # Should we split this up to validate scheme, host, and valid endpoint?
  end

  # Function to test if a url is valid and returns why it is not valid
  def validate_endpoint(changeset, field, opts \\ []) do
    validate_change changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: nil} -> "is missing a scheme (e.g. https)"
        %URI{host: nil} -> "is missing a host"
        %URI{host: host} ->
          case :inet.gethostbyname(Kernel.to_charlist host) do
            {:ok, _} -> nil
            {:error, _} -> "invalid host"
          end
      end
      |> case do
        error when is_binary(error) -> [{field, Keyword.get(opts, :message, error)}]
        _ -> []
      end
    end
  end

end
