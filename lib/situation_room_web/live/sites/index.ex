defmodule SituationRoomWeb.Live.Sites.Index do
  @moduledoc false

  use SituationRoomWeb, :live_view

  alias SituationRoom.Sites

  @impl true
  def mount(_params, %{}, socket) do
    if connected?(socket), do: Sites.subscribe()
    {:ok, assign(socket, %{sites: fetch_sites()})}
  end

  @impl true
  def handle_info({:site_created, site}, socket) do
    {:noreply, update(socket, :sites, fn sites -> [site | sites] end)}
  end

  def handle_info({:site_updated, _site}, socket) do
    {:noreply, update(socket, :sites, fn _sites -> fetch_sites() end)}
  end

  def handle_info({:site_deleted, _site}, socket) do
    {:noreply, update(socket, :sites, fn _sites -> fetch_sites() end)}
  end

  defp fetch_sites do
    Sites.get_all_sites()
  end
end
