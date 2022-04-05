defmodule RESTserver.Repo.Migrations.CreateActiveSites do
  use Ecto.Migration

  def change do
    create table(:active) do
      add :sid, :integer, null: false
      add :is_active, :boolean, null: false
    end
  end
end
