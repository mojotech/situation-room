defmodule SituationRoom.Check.Lib.Behaviour do
  @moduledoc """
  Behavior for all site checking modules
  """
  alias SituationRoom.DTO.Check
  @type t :: %Check{}
  @callback run(check :: Check.t()) :: :ok | :error
end
