defmodule SituationRoom.Site do
  use Ecto.Schema

  schema "sites" do
    field :endpoint, :string
    field :name, :string
  end
end
