defmodule Matchbox.CommonComparisonTest do
  use ExUnit.Case, async: true
  doctest Matchbox.CommonComparison

  describe "operators/0" do
    test "returns expected operators" do
      assert [
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
             ] = Matchbox.CommonComparison.operators()
    end
  end

  describe "operator?" do
    test "returns false if operator not recognized" do
      refute Matchbox.CommonComparison.operator?(:non_existing)
    end

    test "check with  operator is :is_atom" do
      assert Matchbox.CommonComparison.operator?(:is_atom)
    end

    test "check with  operator is :is_binary" do
      assert Matchbox.CommonComparison.operator?(:is_binary)
    end

    test "check with  operator is :is_boolean" do
      assert Matchbox.CommonComparison.operator?(:is_boolean)
    end

    test "check with  operator is :is_float" do
      assert Matchbox.CommonComparison.operator?(:is_float)
    end

    test "check with  operator is :is_function" do
      assert Matchbox.CommonComparison.operator?(:is_function)
    end

    test "check with  operator is :is_integer" do
      assert Matchbox.CommonComparison.operator?(:is_integer)
    end

    test "check with  operator is :is_list" do
      assert Matchbox.CommonComparison.operator?(:is_list)
    end

    test "check with  operator is :is_map" do
      assert Matchbox.CommonComparison.operator?(:is_map)
    end

    test "check with  operator is :is_nil" do
      assert Matchbox.CommonComparison.operator?(:is_nil)
    end

    test "check with  operator is :is_number" do
      assert Matchbox.CommonComparison.operator?(:is_number)
    end

    test "check with  operator is :is_pid" do
      assert Matchbox.CommonComparison.operator?(:is_pid)
    end

    test "check with  operator is :is_port" do
      assert Matchbox.CommonComparison.operator?(:is_port)
    end

    test "check with  operator is :is_reference" do
      assert Matchbox.CommonComparison.operator?(:is_reference)
    end

    test "check with  operator is :is_struct" do
      assert Matchbox.CommonComparison.operator?(:is_struct)
    end

    test "check with  operator is :is_tuple" do
      assert Matchbox.CommonComparison.operator?(:is_tuple)
    end

    test "check with  operator is :===" do
      assert Matchbox.CommonComparison.operator?(:===)
    end

    test "check with  operator is :!==" do
      assert Matchbox.CommonComparison.operator?(:!==)
    end

    test "check with  operator is :<" do
      assert Matchbox.CommonComparison.operator?(:<)
    end

    test "check with  operator is :>" do
      assert Matchbox.CommonComparison.operator?(:>)
    end

    test "check with  operator is :<=" do
      assert Matchbox.CommonComparison.operator?(:<=)
    end

    test "check with  operator is :>=" do
      assert Matchbox.CommonComparison.operator?(:>=)
    end

    test "check with  operator is :=~" do
      assert Matchbox.CommonComparison.operator?(:=~)
    end

    test "check with  operator is :any" do
      assert Matchbox.CommonComparison.operator?(:any)
    end

    test "check with  operator is :in" do
      assert Matchbox.CommonComparison.operator?(:in)
    end
  end

  describe "satisfies?" do
    test "check with operator :is_atom" do
      assert Matchbox.CommonComparison.satisfies?(:matchbox, :is_atom)
    end

    test "check with operator :is_binary" do
      assert Matchbox.CommonComparison.satisfies?("matchbox", :is_binary)
    end

    test "check with operator :is_boolean" do
      assert Matchbox.CommonComparison.satisfies?(false, :is_boolean)
    end

    test "check with operator :is_float" do
      assert Matchbox.CommonComparison.satisfies?(1.0, :is_float)
    end

    test "check with operator :is_function" do
      assert Matchbox.CommonComparison.satisfies?(fn -> :ok end, :is_function)

      assert Matchbox.CommonComparison.satisfies?(fn _ -> :ok end, {:is_function, 1})
    end

    test "check with operator :is_integer" do
      assert Matchbox.CommonComparison.satisfies?(1, :is_integer)
    end

    test "check with operator :is_list" do
      assert Matchbox.CommonComparison.satisfies?([], :is_list)
    end

    test "check with operator :is_map" do
      assert Matchbox.CommonComparison.satisfies?(%{}, :is_map)
    end

    test "check with operator :is_map_key" do
      assert Matchbox.CommonComparison.satisfies?(%{body: "hello"}, {:is_map_key, :body})
    end

    test "check with operator :is_nil" do
      assert Matchbox.CommonComparison.satisfies?(nil, :is_nil)
    end

    test "check with operator :is_number" do
      assert Matchbox.CommonComparison.satisfies?(12.34, :is_number)
    end

    test "check with operator :is_pid" do
      assert Matchbox.CommonComparison.satisfies?(IEx.Helpers.pid("0.0.0"), :is_pid)
    end

    test "check with operator :is_reference" do
      assert Matchbox.CommonComparison.satisfies?(Kernel.make_ref(), :is_reference)
    end

    test "check with operator :is_struct" do
      assert Matchbox.CommonComparison.satisfies?(%Matchbox.Support.ExampleStruct{}, :is_struct)

      assert Matchbox.CommonComparison.satisfies?(
               %Matchbox.Support.ExampleStruct{},
               {:is_struct, Matchbox.Support.ExampleStruct}
             )
    end

    test "check with operator :is_tuple" do
      assert Matchbox.CommonComparison.satisfies?({1, 2, 3}, :is_tuple)
    end

    test "check with operator :===" do
      assert Matchbox.CommonComparison.satisfies?(1, {:===, 1})
    end

    test "check with operator :!==" do
      assert Matchbox.CommonComparison.satisfies?(1, {:!==, 2})
    end

    test "check with operator :>" do
      assert Matchbox.CommonComparison.satisfies?(1, {:>, 0})
    end

    test "check with operator :<" do
      assert Matchbox.CommonComparison.satisfies?(1, {:<, 2})
    end

    test "check with operator :>=" do
      assert Matchbox.CommonComparison.satisfies?(1, {:>=, 1})
    end

    test "check with operator :<=" do
      assert Matchbox.CommonComparison.satisfies?(1, {:<=, 1})
    end

    test "check with operator :=~" do
      assert Matchbox.CommonComparison.satisfies?("example", {:=~, ~r|example|})
    end

    test "check with operator :any" do
      assert Matchbox.CommonComparison.satisfies?({1, 2, 3}, :any)
    end

    test "check with operator :in" do
      assert Matchbox.CommonComparison.satisfies?(1, {:in, [1, 2, 3]})
    end
  end
end
