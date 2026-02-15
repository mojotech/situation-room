defmodule SituationRoom.RequestClient do
  @moduledoc """
  This is a client setup for Tesla - using Hackney instead of default Httpc for ssl
  """
  use Tesla

  adapter(Tesla.Adapter.Finch, name: SituationRoom.Finch)
end
