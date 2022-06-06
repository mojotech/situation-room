defmodule SituationRoom.Check.Validate do
  @moduledoc """
  Module that checks if there is an outage
  """
  alias SituationRoom.Outages

  def head(%SituationRoom.DTO.Check{} = dto) do
    # This will hold a map of each check that is performed.
    head_checks = [
      SituationRoom.Check.Lib.StatusCode.run(dto)
    ]

    Outages.analyze(dto.site_id, head_checks)

    :ok
  end
end
