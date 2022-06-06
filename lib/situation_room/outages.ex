defmodule SituationRoom.Outages do
  @moduledoc """
  Common repository methods for Outages
  """
  import Ecto.Query
  alias SituationRoom.{Notifications, Repo}
  alias SituationRoom.Site.Outage

  def create(params) do
    %Outage{}
    |> Outage.changeset(params)
    |> Repo.insert()
  end

  def get(param) do
    Repo.get_by(Outage, param)
  end

  def get_last(site_id) do
    from(o in Outage, where: o.site_id == ^site_id)
    |> last()
    |> Repo.one()
  end

  def resolve_last(last_outage) do
    last_outage
    |> Outage.changeset(%{resolved: true})
    |> Repo.update!()

    Notifications.send_resolved(last_outage.site_id)
  end

  def analyze(site_id, complete_checks) do
    for result <- complete_checks do
      case result do
        :error ->
          execute(site_id)

        :ok ->
          resolve(site_id)
      end
    end
  end

  def execute(site_id) do
    case get_last(site_id) do
      %SituationRoom.Site.Outage{resolved: result} ->
        case result do
          true ->
            report(site_id)

          false ->
            nil
        end

      nil ->
        report(site_id)
    end
  end

  def report(site_id) do
    create(%{"site_id" => site_id})
    Notifications.send_outage(site_id)
  end

  def resolve(site_id) do
    case get_last(site_id) do
      %SituationRoom.Site.Outage{resolved: result} = last_outage ->
        case result do
          true ->
            nil

          false ->
            resolve_last(last_outage)
        end

      nil ->
        nil
    end
  end
end
