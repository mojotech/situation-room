defmodule SituationRoom.Checks do
  @moduledoc """
  Common repository methods for Site Checks
  """
  alias SituationRoom.Site.Check
  alias SituationRoom.Repo

  def get_all_checks() do
    Repo.all(Check)
  end

  def create_check(%SituationRoom.DTO.Check{} = dto) do
    create_check(%{
      "site_id" => dto.site_id,
      "status_code" => dto.status_code,
      "response_time" => dto.response_time,
      "type" => dto.type,
      "headers" => dto.headers
    })
  end

  def create_check(%Check{} = check) do
    Repo.insert!(check)
  end

  def create_check(params) do
    %Check{}
    |> Check.changeset(params)
    |> Repo.insert()
  end
end
