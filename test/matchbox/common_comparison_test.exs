defmodule Matchbox.CommonComparisonTest do
  use ExUnit.Case, async: true
  doctest Matchbox.CommonComparison

  alias Matchbox.CommonComparison

  @guard_operators [
    :is_atom,
    :is_binary,
    :is_boolean,
    :is_float,
    :is_function,
    :is_integer,
    :is_list,
    :is_map,
    :is_map_key,
    :is_nil,
    :is_number,
    :is_pid,
    :is_port,
    :is_reference,
    :is_struct,
    :is_tuple
  ]

  @comparison_operators [
    :===,
    :!==,
    :>,
    :<,
    :>=,
    :<=,
    :=~
  ]

  @general_operators [
    :length,
    :in
  ]

  @operators @guard_operators ++ @comparison_operators ++ @general_operators

  describe "operators/0" do
    test "returns expected operators" do
      assert @operators = CommonComparison.operators()
    end
  end

  describe "operator?/1" do
    test "returns true for a supported operator" do
      for operator <- @operators do
        assert CommonComparison.operator?(operator)
      end
    end

    test "returns false for an unsupported operator" do
      refute CommonComparison.operator?(:non_existing)
    end
  end

  describe "compare?" do
    test "returns true for valid type checks" do
      assert CommonComparison.compare?(:matchbox, :is_atom)

      assert CommonComparison.compare?("matchbox", :is_binary)

      assert CommonComparison.compare?(false, :is_boolean)

      assert CommonComparison.compare?(1.0, :is_float)

      assert CommonComparison.compare?(fn -> :ok end, :is_function)

      assert CommonComparison.compare?(fn _ -> :ok end, {:is_function, 1})

      assert CommonComparison.compare?(1, :is_integer)

      assert CommonComparison.compare?([], :is_list)

      assert CommonComparison.compare?(%{}, :is_map)

      assert CommonComparison.compare?(%{body: "hello"}, {:is_map_key, :body})

      assert CommonComparison.compare?(nil, :is_nil)

      assert CommonComparison.compare?(12.34, :is_number)

      assert CommonComparison.compare?(IEx.Helpers.pid("0.0.0"), :is_pid)

      assert CommonComparison.compare?(Port.open({:spawn, "cat"}, [:binary]), :is_port)

      assert CommonComparison.compare?(Kernel.make_ref(), :is_reference)

      assert CommonComparison.compare?(%Matchbox.Support.ExampleStruct{}, :is_struct)

      assert CommonComparison.compare?(
               %Matchbox.Support.ExampleStruct{},
               {:is_struct, Matchbox.Support.ExampleStruct}
             )

      assert CommonComparison.compare?({1, 2, 3}, :is_tuple)
    end

    test "returns true for valid comparisons" do
      assert CommonComparison.compare?(1, {:===, 1})
      assert CommonComparison.compare?(1, {:!==, 2})
      assert CommonComparison.compare?(1, {:>, 0})
      assert CommonComparison.compare?(1, {:<, 2})
      assert CommonComparison.compare?(1, {:>=, 1})
      assert CommonComparison.compare?(1, {:<=, 1})
      assert CommonComparison.compare?("example", {:=~, ~r|example|})
      assert CommonComparison.compare?([1, 2, 3], {:in, 1})
    end

    test "supports datetime comparisons" do
      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:===, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:!==, ~U[2025-01-02 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-02 00:00:00.000000Z],
               {:>, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<, ~U[2025-01-02 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:>=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-02 00:00:00.000000Z],
               {:>=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.compare?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<=, ~U[2025-01-02 00:00:00.000000Z]}
             )
    end

    test "supports naive datetime comparisons" do
      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:===, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:!==, ~N[2025-01-02 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-02 00:00:00.000000],
               {:>, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:<, ~N[2025-01-02 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:>=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-02 00:00:00.000000],
               {:>=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:<=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.compare?(
               ~N[2025-01-01 00:00:00.000000],
               {:<=, ~N[2025-01-02 00:00:00.000000]}
             )
    end

    test "supports decimal comparisons" do
      assert CommonComparison.compare?(Decimal.new("1.0"), {:===, Decimal.new("1.0")})
      assert CommonComparison.compare?(Decimal.new("1.0"), {:!==, Decimal.new("2.0")})

      assert CommonComparison.compare?(Decimal.new("2.0"), {:>, Decimal.new("1.0")})
      assert CommonComparison.compare?(Decimal.new("1.0"), {:<, Decimal.new("2.0")})

      assert CommonComparison.compare?(Decimal.new("1.0"), {:>=, Decimal.new("1.0")})
      assert CommonComparison.compare?(Decimal.new("2.0"), {:>=, Decimal.new("1.0")})

      assert CommonComparison.compare?(Decimal.new("1.0"), {:<=, Decimal.new("1.0")})
      assert CommonComparison.compare?(Decimal.new("1.0"), {:<=, Decimal.new("2.0")})
    end
  end
end
