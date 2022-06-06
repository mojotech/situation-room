defmodule SituationRoom.Site.Outage do
  @moduledoc """
  Documentation for `SituationRoom.Site.Outage`.
  An outage is created when a check fails for the site and notification is sent of the outage.
  On following checks, if the check succeeds, the outage is marked as resolved and a resolved notification is sent to all notification addresses associated with the site.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "site_outages" do
    field(:notified_outage, :boolean, default: false)
    field(:notified_resolved, :boolean, default: false)
    field(:resolved, :boolean, default: false)
    belongs_to(:site, SituationRoom.Site)

    timestamps()
  end

  @doc false
  def changeset(outage, attrs) do
    outage
    |> cast(attrs, [:site_id, :resolved, :notified_outage, :notified_resolved])
    |> validate_required([:site_id, :resolved, :notified_outage, :notified_resolved])
  end
end
