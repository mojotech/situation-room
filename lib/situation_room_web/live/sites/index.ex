defmodule SituationRoomWeb.Live.Sites.Index do
  @moduledoc false

  use SituationRoomWeb, :live_view

  alias SituationRoom.Sites

  @impl true
  def mount(_params, %{}, socket) do
    sites = Sites.get_all_sites()

    {:ok, assign(socket, %{sites: sites})}
  end
end
