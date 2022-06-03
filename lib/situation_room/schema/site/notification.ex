defmodule SituationRoom.Site.Notification do
  @moduledoc """
  Documentation for `SituationRoom.Site.Notification`.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "site_notifications" do
    field(:email, :string)
    field(:email_enabled, :boolean, default: false)
    field(:phone, :string)
    field(:sms_enabled, :boolean, default: false)
    belongs_to(:site, SituationRoom.Site)

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:email, :phone, :email_enabled, :sms_enabled])
  end
end
