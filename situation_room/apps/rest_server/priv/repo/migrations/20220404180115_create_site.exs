# https://elixirschool.com/en/lessons/ecto/basics
defmodule RESTserver.Repo.Migrations.CreateSites do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :id, :integer, :serial, null: false
      add :endpoint, :string, null: false
      add :name, :string, null: false
      add :created_at, :integer, null: false
    end
  end
end
