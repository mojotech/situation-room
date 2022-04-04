defmodule RESTserver.Repo do
  use Ecto.Repo,
    otp_app: :rest_server,
    adapter: Ecto.Adapters.Postgres
end
