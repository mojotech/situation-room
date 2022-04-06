defmodule RESTserver.Active do
  use Ecto.Schema
  import Ecto.Changeset

  schema "active" do
    field :sid, :integer
    field :is_active, :boolean
    #belongs_to :site, Site
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:sid, :is_active])
    |> validate_required([:sid, :is_active])
    #|> RESTServer.insert()
  end

end
