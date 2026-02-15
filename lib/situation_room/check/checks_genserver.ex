defmodule SituationRoom.ChecksGenServer do
  @moduledoc """
  The Genserver for checking sites
  """
  use GenServer
  require Logger
  alias SituationRoom.Site.Check

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(site) do
    schedule_site_check(site.interval)
    {:ok, site}
  end

  def handle_info(:run_check, site) do
    handle_check(site)
    schedule_site_check(site.interval)
    {:noreply, site}
  end

  defp handle_check(site) do
    case SituationRoom.Site.LiveCheck.run(site.endpoint) do
      {:ok, %{response_time: res_time, status: status}} ->
        Check.create_check(%{
          "site_id" => site.id,
          "response_time" => res_time,
          "status_code" => status
        })

      {:error, reason} ->
        reason
    end
  end

  defp schedule_site_check(interval) do
    Process.send_after(self(), :run_check, interval)
  end
end
