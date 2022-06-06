defmodule SituationRoom.Check.Manager do
  @moduledoc """
  Logic for sending requests to site URLs
  """
  alias SituationRoom.Check.GetRequest
  alias SituationRoom.Check.Outage
  alias SituationRoom.Checks

  def all_checks(site) do
    GetRequest.run(site.endpoint, site.id)
    |> Checks.insert_check()
    |> Outage.run()
  end
end
