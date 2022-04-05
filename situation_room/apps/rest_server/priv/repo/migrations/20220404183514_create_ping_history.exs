defmodule RESTserver.Repo.Migrations.CreatePingHistory do
  use Ecto.Migration

  def change do
    create table(:ping_history) do
      #add :id, :integer, null: false
      add :sid, :integer, null: false
      add :timestamp, :integer, null: false
      add :result, :boolean, null: false
      add :latency, :integer
    end
  end
end
