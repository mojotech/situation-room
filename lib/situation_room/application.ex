defmodule SituationRoom.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      SituationRoom.Repo
    ]

    opts = [strategy: :one_for_one, name: SituationRoom.Supervisor]
    Supervisor.start_link(children, opts)

  end

end
