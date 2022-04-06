#import RESTserver.PingHistory
defmodule RESTserver.Site do
  use Ecto.Schema
  import Ecto.Changeset
  #import RESTserver.PingHistory
  #import RESTserver.Active

  schema "site" do
    # Ignore the ID Field -> it is default "id" and serial integer
    field :endpoint, :string
    field :name, :string
    field :created_at, :naive_datetime_usec
    #has_many :ping_history, PingHistory
    #has_one :active, Active
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:endpoint, :name])
    |> validate_required([:endpoint, :name])
    #|> RESTServer.insert()
  end

end
