# Matchbox

**Matchbox** provides a standardized way to compare data and check if it
meets specific conditions. Instead of manually writing conditional checks,
you define `conditions` using a **map** or **keyword list**, and Matchbox
evaluates whether the data satisfies them.

This reduces repetitive code and makes comparisons more readable and
maintainable.

## Features

- **Declarative Data Matching** – Define complex matching conditions using
  **maps** or **keyword lists** to avoid repetitive logic.

- **Conditional Transformations** – Modify data **only when** specified
  conditions are met, ensuring predictable updates.

- **Customizable Comparison Logic** – Extend functionality by implementing a
  custom `Matchbox.ComparisonEngine`.

## Installation

Add `matchbox` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:matchbox, "~> 0.1.0"}
  ]
end
```

Then, fetch dependencies:

```sh
mix deps.get
```

## Usage

### Pattern Matching

Elixir’s pattern matching is powerful, but checking **deeply nested data**
manually can be tedious.

Suppose we want to check if a **user** is **30 years old and named Alice**.
A common approach might use a `case` statement:

```elixir
data = %{
  status: "inactive",
  user: %{
    age: 30,
    name: "Alice",
    city: "Vancouver"
  }
}

case data do
  %{user: %{age: 30, name: "Alice"}} -> true
  _ -> false
end
# => true
```

While this works, adding more conditions makes the logic harder to manage
and maintain. Instead of manually writing multiple condition checks, Matchbox
provides a declarative approach that lets us express conditions in a structured
format.

#### **Using Matchbox**

Instead of writing multiple `case` conditions, Matchbox lets us **describe what
we expect** using a **map** or **keyword list**:

```elixir
conditions = %{
  user: %{
    age: 30,
    name: "Alice"
  }
}

Matchbox.matches?(data, conditions)
# => true
```

This approach **keeps logic clear** and allows for easy modifications.


### Data Transformation

Matchbox also supports **conditional transformations**, ensuring updates happen
**only when** conditions are met.

Consider an example where **inactive users should be marked as active**:

```elixir
updated_data = if data.status == "inactive", do: %{data | status: "active"}, else: data
```

With Matchbox, we **separate what we're checking for from what we want to change**:

```elixir
conditions = %{status: "inactive"}

Matchbox.transform(data, conditions, fn d -> %{d | status: "active"} end)
# => %{status: "active", user: %{name: "Alice", age: 30}}
```

If the conditions do not match, the data remains unchanged.


### Custom Comparison Engine

You can define **custom comparison rules** by implementing `Matchbox.ComparisonEngine`,
allowing Matchbox to evaluate conditions based on your own logic.

#### **Example: Custom Comparison Engine**

Create a module implementing `Matchbox.ComparisonEngine`:

```elixir
defmodule MyApp.CustomComparisonEngine do
  @behaviour Matchbox.ComparisonEngine

  @impl true
  def compare?(left, {:===, right}) do
    # Define custom comparison logic
    left === right
  end
end
```

#### **Configuring a Custom Engine**

You can set a custom comparison engine at runtime:

```elixir
Matchbox.matches?(123, :is_integer, comparison_engine: MyApp.CustomComparisonEngine)
```

Or via the configuration option:

```elixir
config :matchbox, :comparison_engine, MyApp.CustomComparisonEngine
```

For more details on built-in comparisons, see `Matchbox.CommonComparison`.


## Documentation

For full API documentation, visit: [HexDocs](https://hexdocs.pm/matchbox).

## License

Matchbox is released under the [MIT License](./LICENSE.txt).

