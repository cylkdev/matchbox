defmodule Matchbox.CommonComparisonTest do
  use ExUnit.Case, async: true
  doctest Matchbox.CommonComparison

  alias Matchbox.CommonComparison

  @operators [
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
    :is_tuple,
    :===,
    :!==,
    :>,
    :<,
    :>=,
    :<=,
    :=~,
    :any,
    :in
  ]

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

  describe "validate?" do
    test "returns true for valid type checks" do
      assert CommonComparison.validate?(:matchbox, :is_atom)

      assert CommonComparison.validate?("matchbox", :is_binary)

      assert CommonComparison.validate?(false, :is_boolean)

      assert CommonComparison.validate?(1.0, :is_float)

      assert CommonComparison.validate?(fn -> :ok end, :is_function)

      assert CommonComparison.validate?(fn _ -> :ok end, {:is_function, 1})

      assert CommonComparison.validate?(1, :is_integer)

      assert CommonComparison.validate?([], :is_list)

      assert CommonComparison.validate?(%{}, :is_map)

      assert CommonComparison.validate?(%{body: "hello"}, {:is_map_key, :body})

      assert CommonComparison.validate?(nil, :is_nil)

      assert CommonComparison.validate?(12.34, :is_number)

      assert CommonComparison.validate?(IEx.Helpers.pid("0.0.0"), :is_pid)

      assert CommonComparison.validate?(Port.open({:spawn, "cat"}, [:binary]), :is_port)

      assert CommonComparison.validate?(Kernel.make_ref(), :is_reference)

      assert CommonComparison.validate?(%Matchbox.Support.ExampleStruct{}, :is_struct)

      assert CommonComparison.validate?(
               %Matchbox.Support.ExampleStruct{},
               {:is_struct, Matchbox.Support.ExampleStruct}
             )

      assert CommonComparison.validate?({1, 2, 3}, :is_tuple)
    end

    test "returns true for valid comparisons" do
      assert CommonComparison.validate?(1, {:===, 1})
      assert CommonComparison.validate?(1, {:!==, 2})
      assert CommonComparison.validate?(1, {:>, 0})
      assert CommonComparison.validate?(1, {:<, 2})
      assert CommonComparison.validate?(1, {:>=, 1})
      assert CommonComparison.validate?(1, {:<=, 1})
      assert CommonComparison.validate?("example", {:=~, ~r|example|})
      assert CommonComparison.validate?({1, 2, 3}, :any)
      assert CommonComparison.validate?(1, {:in, [1, 2, 3]})
    end

    test "supports datetime comparisons" do
      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:===, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:!==, ~U[2025-01-02 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-02 00:00:00.000000Z],
               {:>, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<, ~U[2025-01-02 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:>=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-02 00:00:00.000000Z],
               {:>=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<=, ~U[2025-01-01 00:00:00.000000Z]}
             )

      assert CommonComparison.validate?(
               ~U[2025-01-01 00:00:00.000000Z],
               {:<=, ~U[2025-01-02 00:00:00.000000Z]}
             )
    end

    test "supports naive datetime comparisons" do
      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:===, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:!==, ~N[2025-01-02 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-02 00:00:00.000000],
               {:>, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:<, ~N[2025-01-02 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:>=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-02 00:00:00.000000],
               {:>=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:<=, ~N[2025-01-01 00:00:00.000000]}
             )

      assert CommonComparison.validate?(
               ~N[2025-01-01 00:00:00.000000],
               {:<=, ~N[2025-01-02 00:00:00.000000]}
             )
    end

    test "supports decimal comparisons" do
      assert CommonComparison.validate?(Decimal.new("1.0"), {:===, Decimal.new("1.0")})
      assert CommonComparison.validate?(Decimal.new("1.0"), {:!==, Decimal.new("2.0")})

      assert CommonComparison.validate?(Decimal.new("2.0"), {:>, Decimal.new("1.0")})
      assert CommonComparison.validate?(Decimal.new("1.0"), {:<, Decimal.new("2.0")})

      assert CommonComparison.validate?(Decimal.new("1.0"), {:>=, Decimal.new("1.0")})
      assert CommonComparison.validate?(Decimal.new("2.0"), {:>=, Decimal.new("1.0")})

      assert CommonComparison.validate?(Decimal.new("1.0"), {:<=, Decimal.new("1.0")})
      assert CommonComparison.validate?(Decimal.new("1.0"), {:<=, Decimal.new("2.0")})
    end
  end
end
