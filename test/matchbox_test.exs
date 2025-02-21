defmodule MatchboxTest do
  use ExUnit.Case, async: true
  doctest Matchbox

  describe "transform/3,4" do
    test "applies transformation function when conditions are met" do
      assert Matchbox.transform("hello", %{all: "hello"}, &String.upcase/1) === "HELLO"
    end

    test "returns term unchanged when conditions are not met" do
      assert Matchbox.transform("world", %{all: "hello"}, &String.upcase/1) === "world"
    end

    test "applies transformation function when it has arity 0" do
      assert Matchbox.transform("hello", %{all: "hello"}, fn -> "constant" end) === "constant"
    end

    test "works with :comparison_engine option" do
      assert Matchbox.transform(
               "hello",
               %{all: "hello"},
               &String.upcase/1,
               comparison_engine: Matchbox.Support.ExampleEngine
             ) === "HELLO"
    end
  end

  describe "satisfies?/2,3" do
    test "returns true for exact match" do
      assert Matchbox.satisfies?("hello", %{all: "hello"})
    end

    test "returns false for empty conditions" do
      refute Matchbox.satisfies?("test", %{})
    end

    test "supports keyword list conditions" do
      assert Matchbox.satisfies?("hello", all: "hello")
    end

    test "raises error for invalid qualifiers" do
      assert_raise RuntimeError, fn ->
        Matchbox.satisfies?("test", %{invalid_qualifier: "test"})
      end
    end

    test "returns false when conditions is empty" do
      refute Matchbox.satisfies?("hello", %{})
      refute Matchbox.satisfies?("world", %{})
    end

    test "returns false when expressions in conditions is empty" do
      refute Matchbox.satisfies?("hello", %{all: %{}})
      refute Matchbox.satisfies?("world", %{all: %{}})
    end

    test "returns true when all elements satisfy condition" do
      assert Matchbox.satisfies?([5, 6, 7], %{all: %{>: 4}})
    end

    test "returns false when any element does not satisfy condition" do
      refute Matchbox.satisfies?([1, 2, 3], %{all: %{>: 5}})
    end

    test "handles tuple evaluation" do
      assert Matchbox.satisfies?({:ok, 5}, %{any: :is_integer})
    end

    test "returns false when key does not exist in map" do
      refute Matchbox.satisfies?(%{a: 1}, %{all: %{b: 1}})
    end
  end
end
