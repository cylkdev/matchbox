defmodule MatchboxTest do
  use ExUnit.Case, async: true
  doctest Matchbox

  describe "satisfies?/2 with `all` qualifier" do
    test "returns true when all key-value pairs match the expression" do
      assert Matchbox.satisfies?(%{body: "hello"}, %{all: %{body: "hello"}})
      assert Matchbox.satisfies?([body: "hello"], %{all: %{body: "hello"}})
    end

    test "returns false when at least one key-value pair does not match the expression" do
      refute Matchbox.satisfies?(
               %{topic: "test", body: "not_a_match"},
               %{all: %{topic: "test", body: "hello"}}
             )

      refute Matchbox.satisfies?(
               [topic: "test", body: "not_a_match"],
               %{all: %{topic: "test", body: "hello"}}
             )
    end

    test "returns true when all key-value pairs in a list of maps match the expression" do
      assert Matchbox.satisfies?(
               [%{body: "hello"}, %{body: "hello"}],
               %{all: %{body: "hello"}}
             )

      assert Matchbox.satisfies?(
               [[body: "hello"], [body: "hello"]],
               %{all: %{body: "hello"}}
             )
    end

    test "returns true when both left and right terms match the expression" do
      assert Matchbox.satisfies?(1, %{all: 1})
    end

    test "returns true when all elements in a list match the expression" do
      assert Matchbox.satisfies?([1, 1], %{all: 1})
    end

    test "returns false when at least one element does not match the expression" do
      refute Matchbox.satisfies?([1, 2], %{all: 1})
    end

    test "returns true when all elements in tuples match the expression" do
      assert Matchbox.satisfies?({1, 1, 1}, %{all: 1})
    end
  end

  describe "satisfies?/2 with `any` qualifier" do
    test "returns true when any key-value pair matches the expression" do
      assert Matchbox.satisfies?(
               %{topic: "test", body: "not_a_match"},
               %{any: %{topic: "test", body: "hello"}}
             )

      assert Matchbox.satisfies?(
               [topic: "test", body: "not_a_match"],
               %{any: %{topic: "test", body: "hello"}}
             )
    end

    test "returns true when at least one key-value pair in a list of maps matches the expression" do
      assert Matchbox.satisfies?(
               [%{body: "hello"}, %{body: "hello"}],
               %{any: %{body: "hello"}}
             )

      assert Matchbox.satisfies?(
               [[body: "hello"], [body: "hello"]],
               %{any: %{body: "hello"}}
             )
    end

    test "returns true when at least one element in a list matches the expression" do
      assert Matchbox.satisfies?([1, 1], %{any: 1})
    end

    test "returns false when no elements match the expression" do
      refute Matchbox.satisfies?([1, 2], %{any: 3})
    end
  end

  describe "satisfies?/2 with function matching" do
    test "returns true when the value is a function" do
      assert Matchbox.satisfies?(fn -> :ok end, %{all: :is_function})
      assert Matchbox.satisfies?([fn -> :ok end], %{all: :is_function})
    end

    test "returns true when the value is a function with the expected arity" do
      assert Matchbox.satisfies?(fn _ -> :ok end, %{all: {:is_function, 1}})

      assert Matchbox.satisfies?(
               %{value: fn _ -> :ok end},
               %{all: %{value: {:is_function, 1}}}
             )
    end
  end

  describe "satisfies?/2 with comparison operators" do
    test "returns true when the value matches using `===` operator" do
      assert Matchbox.satisfies?("hello", %{all: %{===: "hello"}})
      assert Matchbox.satisfies?(1, %{all: %{===: 1}})
    end

    test "returns true when the value is greater using `>` operator" do
      assert Matchbox.satisfies?("hello", %{all: %{>: "h"}})
      assert Matchbox.satisfies?(1, %{all: %{>: 0}})
    end

    test "returns true when the value is less using `<` operator" do
      assert Matchbox.satisfies?("h", %{all: %{<: "hello"}})
      assert Matchbox.satisfies?(0, %{all: %{<: 1}})
    end

    test "returns true when the value is greater using `>=` operator" do
      assert Matchbox.satisfies?("h", %{all: %{>=: "h"}})
      assert Matchbox.satisfies?("hello", %{all: %{>=: "h"}})
      assert Matchbox.satisfies?(0, %{all: %{>=: 0}})
      assert Matchbox.satisfies?(1, %{all: %{>=: 0}})
    end

    test "returns true when the value is equal to or less using `<=` operator" do
      assert Matchbox.satisfies?("h", %{all: %{<=: "h"}})
      assert Matchbox.satisfies?("h", %{all: %{<=: "hello"}})
      assert Matchbox.satisfies?(0, %{all: %{<=: 0}})
      assert Matchbox.satisfies?(0, %{all: %{<=: 1}})
    end
  end

  describe "satisfies?/2 with struct matching" do
    test "returns true when the value is a struct of the specified name" do
      assert Matchbox.satisfies?(%Matchbox.Support.ExampleStruct{body: "hello"}, %{
               all: {:is_struct, Matchbox.Support.ExampleStruct}
             })
    end

    test "returns true when the struct and all specified fields match the expression" do
      assert Matchbox.satisfies?(%Matchbox.Support.ExampleStruct{body: "hello"}, %{
               all: %{is_struct: Matchbox.Support.ExampleStruct, body: "hello"}
             })
    end

    test "returns false when at least one specified field does not match the expression" do
      refute Matchbox.satisfies?(%Matchbox.Support.ExampleStruct{body: "not_a_match"}, %{
               all: %{is_struct: Matchbox.Support.ExampleStruct, body: "hello"}
             })
    end
  end

  describe "satisfies?/2 with boolean matching" do
    test "returns true when the value is a boolean" do
      assert Matchbox.satisfies?(false, %{all: :is_boolean})
    end

    test "returns true when a key in a enum matches the boolean type" do
      assert Matchbox.satisfies?(%{body: "hello", success: true}, %{
               all: %{success: :is_boolean}
             })

      assert Matchbox.satisfies?([body: "hello", success: true], %{
               all: %{success: :is_boolean}
             })
    end
  end

  describe "transform/5" do
    test "can match on value and return new term" do
      assert "HELLO" =
               Matchbox.transform(
                 "hello",
                 %{all: "hello"},
                 fn val -> String.upcase(val) end
               )
    end
  end
end
