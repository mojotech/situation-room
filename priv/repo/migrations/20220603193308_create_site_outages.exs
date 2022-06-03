defmodule SituationRoom.Repo.Migrations.CreateSiteOutages do
  use Ecto.Migration

  def change do
    create table(:site_outages) do
      add :site_id, references(:sites, on_delete: :delete_all), null: false
      add :resolved, :boolean, default: false, null: false
      add :notified_outage, :boolean, default: false, null: false
      add :notified_resolved, :boolean, default: false, null: false

      timestamps()
    end
  end
end
