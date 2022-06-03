defmodule SituationRoom.Repo.Migrations.AddSitesTimestamps do
  use Ecto.Migration

  def change do
    alter table (:sites) do
      timestamps()
    end
  end
end
