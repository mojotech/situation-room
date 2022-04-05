defmodule RESTserver.Active do
  use Ecto.Schema

  schema "active" do
    field :sid, :integer
    field :is_active, :boolean
    belongs_to :site, Site
  end
end
