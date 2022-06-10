defmodule SituationRoomWeb.Live.Index do
  @moduledoc false

  use SituationRoomWeb, :live_view

  alias SituationRoom.Sites

  def mount(_params, %{}, socket) do
    sites = Sites.get_all_sites()

    {:ok, assign(socket, :sites, sites)}
  end
end
