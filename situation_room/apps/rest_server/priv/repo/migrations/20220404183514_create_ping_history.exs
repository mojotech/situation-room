defmodule RESTserver.Repo.Migrations.CreatePingHistory do
  use Ecto.Migration

  def change do
    add :id, :integer, :serial, null: false
    add :sid, :integer, null: false
    add :timestamp, :integer, null: false
    add :result, :boolean, null: false
    add :latency, :integer
  end
end
