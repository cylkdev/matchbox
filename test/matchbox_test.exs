defmodule MatchboxTest do
  use ExUnit.Case, async: true
  doctest Matchbox

  describe "transform: " do
    test "applies the transformation function when conditions are met" do
      assert Matchbox.transform("hello", %{all: "hello"}, &String.upcase/1) === "HELLO"
    end

    test "returns the original term when conditions are not met" do
      assert Matchbox.transform("world", %{all: "hello"}, &String.upcase/1) === "world"
    end

    test "applies the transformation function when it has arity 0" do
      assert Matchbox.transform("hello", %{all: "hello"}, fn -> "constant" end) === "constant"
    end

    test "supports the :comparison_engine option" do
      assert "HELLO" =
               Matchbox.transform("hello", %{all: "hello"}, &String.upcase/1,
                 comparison_engine: Matchbox.Support.ExampleEngine
               )
    end
  end

  describe "satisfies?: " do
    test "returns true for an exact string match" do
      assert Matchbox.satisfies?("hello", %{all: "hello"})
    end

    test "returns true for an exact integer match" do
      assert Matchbox.satisfies?(1, %{all: 1})
    end

    test "returns true for an exact float match" do
      assert Matchbox.satisfies?(1.0, %{all: 1.0})
    end

    test "returns true for an exact boolean match" do
      assert Matchbox.satisfies?(true, %{all: true})
      assert Matchbox.satisfies?(false, %{all: false})
    end

    test "returns true for an exact map match" do
      assert Matchbox.satisfies?(%{body: "hello"}, %{all: %{body: "hello"}})
    end

    test "returns true for an exact keyword list match" do
      assert Matchbox.satisfies?([body: "hello"], %{all: %{body: "hello"}})
    end

    test "returns true for an exact tuple match" do
      assert Matchbox.satisfies?({1, 2, 3}, %{all: {1, 2, 3}})
    end

    test "returns false when tuples do not match exactly" do
      refute Matchbox.satisfies?({1, 2}, %{all: {1, 2, 3}})
      refute Matchbox.satisfies?({1, 2, 3}, %{all: {1, 2}})
    end

    test "returns true for an exact list match" do
      assert Matchbox.satisfies?([1, 2, 3], %{all: [1, 2, 3]})
    end

    test "returns false when lists do not match exactly" do
      refute Matchbox.satisfies?([1, 2], %{all: [1, 2, 3]})
      refute Matchbox.satisfies?([1, 2, 3], %{all: [1, 2]})
    end

    test "returns true when a datetime matches exactly" do
      assert Matchbox.satisfies?(~U[2025-01-01 00:00:00.000000Z], %{
               all: %{===: ~U[2025-01-01 00:00:00.000000Z]}
             })
    end

    test "supports engine operators" do
      assert Matchbox.satisfies?(&Function.identity/1, %{all: {:is_function, 1}})
    end

    test "matches nested list values" do
      assert Matchbox.satisfies?([[%{count: 1}]], %{all: %{count: %{>: 0}}})
    end

    test "matches values within an enum" do
      assert Matchbox.satisfies?(%{count: 1}, all: %{count: %{>: 0}})
    end

    test "returns false when conditions are empty" do
      refute Matchbox.satisfies?("test", %{})
    end

    test "supports keyword list conditions" do
      assert Matchbox.satisfies?("hello", all: "hello")
    end

    test "raises an error for an invalid qualifier" do
      assert_raise ArgumentError, fn ->
        Matchbox.satisfies?("test", %{invalid_qualifier: "test"})
      end
    end

    test "raises an error for an invalid conditions argument" do
      assert_raise ArgumentError, fn ->
        Matchbox.satisfies?("test", [{1, 2, 3}])
      end
    end

    test "returns false when expressions in conditions are empty" do
      refute Matchbox.satisfies?("hello", %{all: %{}})
      refute Matchbox.satisfies?("world", %{all: %{}})
    end

    test "returns true when all elements satisfy a condition" do
      assert Matchbox.satisfies?([5, 6, 7], %{all: %{>: 4}})
    end

    test "returns false when the condition structure does not match the data type" do
      refute Matchbox.satisfies?(1, %{all: %{count: 4}})
    end

    test "returns false when any element does not satisfy a condition" do
      refute Matchbox.satisfies?([1, 2, 3], %{all: %{>: 5}})
    end

    test "evaluates tuples correctly" do
      assert Matchbox.satisfies?({:ok, 5}, %{any: :is_integer})
    end

    test "returns false when a key does not exist in an enum" do
      refute Matchbox.satisfies?(%{a: 1}, %{all: %{b: 1}})
      refute Matchbox.satisfies?([a: 1], %{all: %{b: 1}})
    end
  end
end
