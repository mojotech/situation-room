defmodule SituationRoom.DTO.Check do
  @moduledoc """
  DTO that holds the data when a check is performed
  """
  use Ecto.Schema

  defstruct [
    :site_id,
    :status_code,
    :response_time,
    :type,
    :headers,
    :body
  ]
end
