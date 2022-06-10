defmodule SituationRoomWeb.Live.Sites.Index do
  @moduledoc false

  use SituationRoomWeb, :live_view

  def mount(_params, %{}, socket) do
    sites = SituationRoom.Sites.get_all_sites()

    {:ok, assign(socket, %{sites: sites})}
  end
end
