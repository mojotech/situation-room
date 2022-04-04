defmodule RESTserver.PingHistory do
  use Ecto.Schema

  schema "ping_history" do
    #field :id, :integer
    field :sid, :integer
    field :timestamp, :integer
    field :result, :boolean
    field :latency, :integer
  end
end
