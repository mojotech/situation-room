defmodule SituationRoom.Sites.CheckIntervals do
  @moduledoc """
  Helper module for defining check frequency intervals.
  """

  defp intervals() do
    %{
      60 => '1 minute',
      180 => '3 minutes',
      300 => '5 minutes',
      600 => '10 minutes',
      900 => '15 minutes',
      1800 => '30 minutes',
      3600 => '1 hour',
      7200 => '2 hours',
      14_400 => '4 hours',
      28_800 => '8 hours',
      43_200 => '12 hours',
      86_400 => '24 hours'
    }
  end

  @doc """
  For a given interval, return the string representation of the interval.
  """
  def get_interval_string(interval) do
    intervals()[interval]
  end

  @doc """
  Return a keyword list of all interval options for the form select options.
  """
  def get_interval_options() do
    Enum.map(intervals(), fn {key, val} -> {val, key} end)
  end
end
