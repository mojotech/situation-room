defmodule SituationRoom.Site.LiveCheck do
  @moduledoc """
  Logic for sending requests to site URLs
  """
  alias SituationRoom.RequestClient

  @spec run(binary) :: {:error, any} | {:ok, %{response_time: integer, status: nil | integer}}
  def run(url) do
    try do
      start_ms = :os.system_time(:millisecond)
      res = RequestClient.head!(url)
      {:ok, %{status: res.status, response_time: :os.system_time(:millisecond) - start_ms}}
    rescue
      e in ArgumentError -> {:error, e.message}
      e in Tesla.Error -> {:error, e.reason}
      FunctionClauseError -> {:error, :not_found}
    end
  end
end
