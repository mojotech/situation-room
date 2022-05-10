defmodule SituationRoom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:situation_room, :port) || 4001

    # List all child processes to be supervised
    children = [
      SituationRoom.Repo,
      {Plug.Cowboy, scheme: :http, plug: SituationRoom.Router, options: [port: port]}
    ]
    opts = [strategy: :one_for_one, name: SituationRoom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
