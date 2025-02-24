defmodule Matchbox.Support.ExampleEngine do
  @moduledoc false

  @behaviour Matchbox.ComparisonEngine

  @impl Matchbox.ComparisonEngine
  def operators, do: [:===]

  @impl Matchbox.ComparisonEngine
  def operator?(:===), do: true
  def operator?(_), do: false

  @impl Matchbox.ComparisonEngine
  def compare?(left, {:===, right}), do: left === right
end
