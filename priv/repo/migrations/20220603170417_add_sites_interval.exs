defmodule SituationRoom.Repo.Migrations.AddSitesInterval do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add :interval, :integer, default: 300, null: false
    end
  end
end
