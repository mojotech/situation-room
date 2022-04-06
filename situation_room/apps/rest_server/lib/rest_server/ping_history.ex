defmodule RESTserver.PingHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ping_history" do
    #field :id, :integer
    field :sid, :integer
    field :timestamp, :naive_datetime_usec
    field :result, :boolean
    field :latency, :integer
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:sid, :result])
    |> validate_required([:sid, :result])
    #|> RESTServer.insert()
  end

end
