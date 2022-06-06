defmodule SituationRoom.Check.Behaviour do
  @moduledoc """
  Behavior for all site checking modules
  """
  alias SituationRoom.Site.Check
  @type t :: %Check{}
  @callback run(check :: Check.t()) :: {:ok} | {:error}
end
