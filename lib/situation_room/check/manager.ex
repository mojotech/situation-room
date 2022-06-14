defmodule SituationRoom.Check.Manager do
  @moduledoc """
  Logic for sending requests to site URLs
  """
  alias SituationRoom.Check.{Request, Validate}
  alias SituationRoom.Checks

  def head_check(%SituationRoom.Site{} = site) do
    dto = Request.head(site)
    Checks.create_check(dto)
    Validate.head(dto)
  end
end
