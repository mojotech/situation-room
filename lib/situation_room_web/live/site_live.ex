defmodule SituationRoomWeb.SiteLive do
  @moduledoc false

  use SituationRoomWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="phx-hero">
      <%= button "Add New Site", to: Routes.site_path(@socket, :new), method: :get %>
      <%= for site <- @sites do %>
        <div>
          <h1><%= site.name %></h1>
          <h3>
            <%= site.endpoint %>
          </h3>
        </div>
      <% end %>
    </section>
    """
  end

  def mount(_params, %{}, socket) do
    sites = SituationRoom.Sites.get_all_sites()

    {:ok, assign(socket, :sites, sites)}
  end
end
