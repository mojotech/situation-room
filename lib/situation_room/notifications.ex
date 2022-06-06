defmodule SituationRoom.Notifications do
  @moduledoc """
  Common Repository Methods for the Notification Data model
  """
  alias SituationRoom.Repo
  alias SituationRoom.Site.Notification

  def get_all() do
    Repo.all(Notification)
  end

  def create(params) do
    %Notification{}
    |> Notification.changeset(params)
    |> Repo.insert()
  end

  def send_outage(_site_id) do
    nil
  end

  def send_resolved(_site_id) do
    nil
  end
end
