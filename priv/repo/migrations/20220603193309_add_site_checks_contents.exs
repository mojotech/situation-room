defmodule SituationRoom.Repo.Migrations.CreateSiteOutages do
  use Ecto.Migration

  def change do
    alter table(:site_checks) do
      add :type, :string, default: "head", null: false
      add :headers, {:array, :map}
      add :body, :string
    end
  end
end
