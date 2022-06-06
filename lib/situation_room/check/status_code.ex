defmodule SituationRoom.Check.StatusCode do
  @moduledoc """
  Module that checks the status code
  """
  @behaviour SituationRoom.Check.Behaviour

  @impl true
  def run(check) do
    case check.status_code do
      x when x in 100..399 -> {:ok}
      _ -> {:error}
    end
  end
end
