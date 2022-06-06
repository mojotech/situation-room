defmodule SituationRoom.Outages do
  @moduledoc """
  Common repository methods for Outages
  """

  alias SituationRoom.Repo
  alias SituationRoom.Site.Outage

  def create(params) do
    %Outage{}
    |> Outage.changeset(params)
    |> Repo.insert()
  end
end
