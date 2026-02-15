defmodule SituationRoom.CheckTest do
  use ExUnit.Case, async: true
  alias SituationRoom.Site.LiveCheck

  @test_suites [
    {301, "https://google.com"},
    {301, "https://mojotech.com"},
    {"non-existing domain", "https://someinvalidmojotechdomain.com"},
    {"scheme is required for url: localhost", "localhost"},
    {"scheme is required for url: ", "127.0.0.1"},
    {"invalid scheme \"ht\" for url: ht://facebook.com", "ht://facebook.com"},
    {"non-existing domain", ""},
    {:not_found, 5}
  ]

  for i <- @test_suites do
    mac = Macro.escape(i)

    test "Return Check for #{elem(i, 1)}" do
      test_case = unquote(mac)

      case LiveCheck.run(elem(test_case, 1)) do
        {:ok, %{response_time: res_time, status: received_status}} ->
          assert received_status = elem(test_case, 0)
          assert is_number(res_time)

        {:error, reason} ->
          assert reason = elem(test_case, 0)
      end
    end
  end
end
