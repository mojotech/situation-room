import Config

config :situation_room, SituationRoom.Repo,
  database: "situation_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :situation_room, ecto_repos: [SituationRoom.Repo]
