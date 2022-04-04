defmodule RESTserver.Site do
  use Ecto.Schema

  schema "site" do
    #field :id, :integer
    field :endpoint, :string
    field :name, :string
    field :created_at, :integer
  end
end
