defmodule SituationRoom.Checks do
  @moduledoc """
  Common repository methods for Site Checks
  """
  alias SituationRoom.Site.Check
  alias SituationRoom.Repo

  def get_all_checks() do
    Repo.all(Check)
  end

  def create_check(params) do
    %Check{}
    |> Check.changeset(params)
    |> Repo.insert()
  end

  def insert_check(%Check{} = check) do
    check |> Repo.insert!()
  end
end
