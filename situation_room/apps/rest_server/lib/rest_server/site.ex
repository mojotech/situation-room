defmodule RESTserver.Site do
  use Ecto.Schema

  schema "site" do
    #field :id, :integer
    field :endpoint, :string
    field :name, :string
    field :created_at, :naive_datetime_usec
    has_many :ping_history, PingHistory
    has_one :active, Active
  end
end
