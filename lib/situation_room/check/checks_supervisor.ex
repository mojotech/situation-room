defmodule SituationRoom.ChecksSupervisor do
  @moduledoc """
  Supervisor for Site Check GenServers
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_opts) do
    children =
      for site <- SituationRoom.Sites.get_all_sites() do
        Supervisor.child_spec({SituationRoom.ChecksGenServer, site}, id: site.id)
      end

    Supervisor.init(children, strategy: :one_for_one)
  end

  # def add_child(site) do
  #   Supervisor.start_child()
  # end

  # def remove_child() do
  #   Supervisor.delete_child()
  # end
end
