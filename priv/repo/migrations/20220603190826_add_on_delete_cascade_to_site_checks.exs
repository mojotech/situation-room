defmodule SituationRoom.Repo.Migrations.AddOnDeleteCascadeToSiteChecks do
  use Ecto.Migration

  def change do
    execute "ALTER TABLE site_checks DROP CONSTRAINT site_checks_site_id_fkey;"
    execute "ALTER TABLE site_checks ADD CONSTRAINT site_checks_site_id_fk FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE;"
  end
end
