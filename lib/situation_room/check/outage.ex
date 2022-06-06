defmodule SituationRoom.Check.Outage do
  @moduledoc """
  Module that checks if there is an outage
  """
  alias SituationRoom.Outages
  @behaviour SituationRoom.Check.Behaviour

  @impl true
  def run(check) do
    # This will hold a map of each check that is performed.
    checklist_of_checks = %{
      :status_code => SituationRoom.Check.StatusCode.run(check)
    }

    # Iterate through the map of checks to analyze the results
    for {k, v} <- checklist_of_checks do
      case v do
        {:error} ->
          do_outage(check, k)

        {:ok} ->
          nil
      end
    end

    {:ok}
  end

  def do_outage(check, _reason) do
    # Using a site_id, get the latest outage and check if it is resolved.
    # If there is no latest outage or the latest outage is resolved, then create an outage
    Outages.create(%{"site_id" => check.site_id})
  end
end
