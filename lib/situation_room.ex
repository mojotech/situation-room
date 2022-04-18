defmodule SituationRoom do
  use Application

  @spec start(atom, list) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      SituationRoom.Repo
    ]

    opts = [strategy: :one_for_one, name: SituationRoom.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
