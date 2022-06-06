defmodule SituationRoom.Repo.Migrations.SituationRoom.Site.Check do
  use Ecto.Migration

  def change do
    create table(:site_checks) do
      add :site_id, references(:sites), null: false
      add :status_code, :integer, null: false
      add :response_time, :float, null: false
      add :type, :string, default: "head", null: false
      add :headers, {:array, :map}
      add :body, :string

      timestamps()
    end
  end
end
