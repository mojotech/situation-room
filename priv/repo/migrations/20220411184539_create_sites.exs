defmodule Situation_Room.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :endpoint, :string, null: false
      add :name, :string, null: false
    end
  end
end
