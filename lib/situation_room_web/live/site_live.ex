defmodule SituationRoomWeb.SiteLive do
  @moduledoc false

  use SituationRoomWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="phx-hero">
      <%= @sites %>
    </section>
    """
  end

  def mount(_params, %{}, socket) do
    sites = SituationRoom.Site.get_all_sites()

    {:ok, assign(socket, :sites, sites)}
  end
end
