defmodule SituationRoom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SituationRoom.Repo,
      # Start the Telemetry supervisor
      SituationRoomWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SituationRoom.PubSub},
      # Start the Endpoint (http/https)
      SituationRoomWeb.Endpoint,
      # Start a worker by calling: SituationRoom.Worker.start_link(arg)
      # {SituationRoom.Worker, arg}
      {Finch, name: SituationRoom.Finch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SituationRoom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SituationRoomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
