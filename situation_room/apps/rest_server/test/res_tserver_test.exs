defmodule RESTserverTest do
  use ExUnit.Case
  doctest RESTserver

  test "greets the world" do
    assert RESTserver.hello() == :world
  end
end
