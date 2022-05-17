defmodule SituationRoom.Site.Check do
  @moduledoc """
  Documentation for `SituationRoom.Ping`.
  """
  @derive {Jason.Encoder, except: [:__meta__]}
  use Ecto.Schema
  import Ecto.Changeset
  alias SituationRoom.Repo

  schema "site_checks" do
    field(:status_code, :integer)
    field(:response_time, :float)
    belongs_to(:site, SituationRoom.Site)

    timestamps()
  end

  def changeset(check, params) do
    check
    |> cast(params, [:site_id, :status_code, :response_time])
    |> validate_required([:site_id, :status_code, :response_time])
  end

  def get_all_checks() do
    Repo.all(SituationRoom.Site.Check)
  end

  @spec create_check(any()) :: any()
  def create_check(params) do
    %SituationRoom.Site.Check{}
    |> changeset(params)
    |> Repo.insert()
  end
end
