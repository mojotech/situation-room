import Config

config :situation_room, SituationRoom.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("POSTGRES_DB"),
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOSTNAME"),
  # Correlates directly with database timeout error
  ownership_timeout: 300_000

config :situation_room,
  ecto_repos: [SituationRoom.Repo],
  env: Mix.env()

config :situation_room, SituationRoom.Application, port: System.get_env("PORT")
import_config "#{Mix.env()}.exs"
