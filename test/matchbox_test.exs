defmodule MatchboxTest do
  use ExUnit.Case, async: true
  doctest Matchbox

  describe "transform: " do
    test "applies the transformation function when params is met" do
      assert {"HELLO", true} = Matchbox.transform("hello", {"hello", &String.upcase/1})
    end

    test "returns the original term when params does not match" do
      assert {"world", false} = Matchbox.transform("world", {"hello", &String.upcase/1})
    end

    test "applies the transformation function when it has arity 0" do
      assert {"constant", true} = Matchbox.transform("hello", {"hello", fn -> "constant" end})
    end

    test "supports the :comparison_engine option" do
      assert {"HELLO", true} =
               Matchbox.transform("hello", {"hello", &String.upcase/1},
                 comparison_engine: Matchbox.Support.ExampleEngine
               )
    end
  end

  describe "matches?: " do
    test "can match struct" do
      assert Matchbox.matches?(
               %Matchbox.Support.ExampleStruct{body: "hello"},
               %{is_struct: Matchbox.Support.ExampleStruct, body: "hello"}
             )

      refute Matchbox.matches?(
               %Matchbox.Support.ExampleStruct{body: "hello"},
               %{is_struct: NonExistingStruct, body: "hello"}
             )
    end

    test "returns true for literal match" do
      assert Matchbox.matches?("hello", %{===: "hello"})
    end

    test "returns true for an exact string match" do
      assert Matchbox.matches?("hello", "hello")
    end

    test "returns true for an exact integer match" do
      assert Matchbox.matches?(1, 1)
    end

    test "returns true for an exact float match" do
      assert Matchbox.matches?(1.0, 1.0)
    end

    test "returns true for an exact boolean match" do
      assert Matchbox.matches?(true, true)
      assert Matchbox.matches?(false, false)
    end

    test "returns true for an exact map match" do
      assert Matchbox.matches?(%{body: "hello"}, %{body: "hello"})
    end

    test "returns true for an exact keyword list match" do
      assert Matchbox.matches?([body: "hello"], %{body: "hello"})
    end

    test "returns true for an exact tuple match" do
      assert Matchbox.matches?({1, 2, 3}, {1, 2, 3})
    end

    test "returns true for an exact list match" do
      assert Matchbox.matches?([1, 2, 3], %{===: [1, 2, 3]})
    end

    test "returns false when lists do not match exactly" do
      refute Matchbox.matches?([1, 2], [1, 2, 3])
      refute Matchbox.matches?([1, 2, 3], [1, 2])
    end

    test "returns true when a datetime matches exactly" do
      assert Matchbox.matches?(~U[2025-01-01 00:00:00.000000Z], %{
               all?: %{===: ~U[2025-01-01 00:00:00.000000Z]}
             })
    end

    test "supports engine operators" do
      assert Matchbox.matches?(&Function.identity/1, {:is_function, 1})
    end

    test "matches values within an enum" do
      assert Matchbox.matches?(%{count: 1}, %{count: %{>: 0}})
    end

    test "returns false when params is empty" do
      refute Matchbox.matches?("test", %{})
    end

    test "supports keyword list params" do
      assert Matchbox.matches?("hello", ===: "hello")
    end

    test "returns false when expression in params is empty" do
      refute Matchbox.matches?("hello", %{})
      refute Matchbox.matches?("world", %{})
    end

    test "returns true when all elements satisfy a condition" do
      assert Matchbox.matches?([5, 6, 7], %{>: 4})
    end

    test "returns false when the condition structure does not match the data type" do
      refute Matchbox.matches?(1, %{count: 4})
    end

    test "returns false when any element does not satisfy a condition" do
      refute Matchbox.matches?([1, 2], "not_a_match")
    end

    test "returns false when a key does not exist in an enum" do
      refute Matchbox.matches?(%{a: 1}, %{b: 1})
      refute Matchbox.matches?([a: 1], %{b: 1})
    end
  end
end
