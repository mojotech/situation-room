defmodule SituationRoom.Check.Request do
  @moduledoc """
  Module that sends a head request to a site's url
  Retrieves a status code and a response time
  """
  alias SituationRoom.DTO.Check

  def head(%SituationRoom.Site{} = site) do
    start = :os.system_time(:microsecond)
    response = SituationRoom.Check.Client.head(site.endpoint)
    time = (:os.system_time(:microsecond) - start) / 1000

    case response do
      {:ok, %Tesla.Env{} = env} ->
        %Check{
          site_id: site.id,
          type: "head",
          headers: Enum.map(env.headers, fn {k, v} -> %{k => v} end),
          response_time: time,
          status_code: env.status
        }

      {:error, _reason} ->
        %Check{
          site_id: site.id,
          type: "head",
          response_time: time,
          status_code: -1
        }
    end
  end
end
