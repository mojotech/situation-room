defmodule SituationRoom.Check.Client do
  @moduledoc """
  This is a client setup for Tesla
  """
  use Tesla

  adapter(Tesla.Adapter.Finch, name: SituationRoom.Finch)
end
