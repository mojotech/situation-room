defmodule SituationRoom.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :endpoint, :string
    field :name, :string
  end

  def changeset(site, params) do
    site
    |> cast(params, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
  end

end
