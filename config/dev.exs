import Config

config :situation_room, SituationRoom.Repo,
  database: System.get_env("POSTGRES_DB"),
  username: System.get_env("POSTGRES_USER"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOSTNAME"),
  pool: Ecto.Adapters.SQL.Sandbox

config :situation_room,
  ecto_repos: [SituationRoom.Repo]
