defmodule SituationRoom.Repo do
  use Ecto.Repo,
    otp_app: :situation_room,
    adapter: Ecto.Adapters.Postgres
end
