defmodule SituationRoomWeb.ControllerCheckTest do
  use SituationRoomWeb.ConnCase, async: true
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SituationRoom.Repo)
  end
end
