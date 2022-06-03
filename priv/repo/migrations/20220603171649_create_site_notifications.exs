defmodule SituationRoom.Repo.Migrations.CreateSiteNotifications do
  use Ecto.Migration

  def change do
    create table(:site_notifications) do
      add :site_id, references(:sites, on_delete: :delete_all), null: false
      add :email, :string
      add :phone, :string
      add :email_enabled, :boolean, default: false, null: false
      add :sms_enabled, :boolean, default: false, null: false

      timestamps()
    end
  end
end
