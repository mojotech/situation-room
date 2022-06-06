defmodule SituationRoom.Site.Check do
  @moduledoc """
  Documentation for `SituationRoom.Ping`.
  """
  @derive {Jason.Encoder, except: [:__meta__, :site]}
  use Ecto.Schema
  import Ecto.Changeset

  schema "site_checks" do
    field(:status_code, :integer)
    field(:response_time, :float)
    field(:type, :string, default: "head", null: false)
    field(:headers, {:array, :map})
    field(:body, :string)
    belongs_to(:site, SituationRoom.Site)

    timestamps()
  end

  def changeset(check, params) do
    check
    |> cast(params, [:site_id, :status_code, :response_time])
    |> validate_required([:site_id, :status_code, :response_time])
  end

  def changeset(whole_check) do
    validate_required(whole_check, [:site_id, :status_code, :response_time])
  end
end
