# Matchbox

Matchbox is an Elixir library that enhances native pattern matching in
Elixir by providing a declarative API for complex data structures. It
streamlines comparing and transforming nested data, reducing
boilerplate and improving code maintainability.

## Features

  – Declaratively match nested structures.

  – Modify terms based on pattern matching rules.

  – Simple and readable syntax.

## Installation

Add `matchbox` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:matchbox, "~> 0.1.0"}
  ]
end
```

Then, fetch the dependencies:

```sh
mix deps.get
```

## Usage

### Pattern Matching in Elixir vs. Matchbox

Pattern matching in Elixir is powerful, but handling deeply nested structures
can require multiple conditions, making the code more complex over time.

Consider the following standard Elixir approach:

```elixir
case data do
  %{user: %{age: 30, name: "alice"}} -> true
  _ -> false
end
```

Here, we check if the data map contains a user key with an age of 30 and
a name of "alice". This approach works but becomes harder to manage as
conditions grow.

With `Matchbox`, we can express the same logic more declaratively:

```elixir
data = %{user: %{age: 30, name: "alice", city: "Vancouver"}}

conditions = %{all: %{user: %{age: 30, name: "alice"}}}

Matchbox.match_conditions?(data, conditions)
# => true
```

Here, `match_conditions?/2` checks if all specified conditions are met in
the data structure, making it more readable and maintainable.

### Handling Non-Matching Cases

When conditions do not match, Matchbox returns false instead of requiring
manual case handling.

```elixir
data = %{status: "pending"}

conditions = %{all: %{status: "active"}}

Matchbox.match_conditions?(data, conditions)
# => false
```

This approach eliminates the need for multiple case conditions to determine mismatches.

### Filtering Nested Data with Conditions

`Matchbox` simplifies filtering collections by allowing expressive queries on
nested structures.

Consider filtering a list of users where the status is active, the id is
greater than 1, and the name starts with "A":

```elixir
data = [
  %{status: :inactive, user: %{id: 1, name: "annie"}},
  %{status: :active, user: %{id: 2, name: "bart"}},
  %{status: :active, user: %{id: 3, name: "alice"}}
]

conditions = %{
  all: %{
    status: :active,
    user: %{id: %{>: 1},
    name: %{=~: ~r/^a(.*)/}}
  }
}

Enum.filter(data, &Matchbox.match_conditions?(&1, conditions))
# => [%{status: :active, user: %{id: 3, name: "alice"}}]
```

This is significantly more readable than manually iterating and filtering
within a standard `Enum.filter/2` function.

### Transforming Data in Matchbox

Modifying deeply nested structures in Elixir often requires using functions
like `Map.merge/2` or recursive updates.

Consider the following approach:

```elixir
Map.merge(data, %{status: "active"})
```

This works well for shallow updates but becomes cumbersome for deeper
structures. Matchbox provides a cleaner way to apply transformations
only when all conditions match:

```elixir
data = %{user: %{name: "alice", age: 30}, status: "inactive"}

conditions = %{all: %{status: "inactive"}}

Matchbox.transform(data, conditions, fn data -> %{data | status: "active"} end)
# => %{status: "active", user: %{name: "alice", age: 30}}
```

If no match occurs, the data remains unchanged:

```elixir
data = %{user: %{name: "alice", age: 30}, status: "inactive"}

conditions = %{all: %{name: "bart"}}

Matchbox.transform(data, conditions, fn data -> %{data | status: "active"} end)
# => %{user: %{name: "alice", age: 30}, status: "inactive"}
```

This ensures transformations are applied only when intended, preventing
accidental updates.

#### Custom Comparison Engine

Matchbox allows customization of the comparison logic by implementing the
`Matchbox.ComparisonEngine` behavior. This is useful when you need to
define custom operators or modify existing comparison behaviors.

#### Implementing a Custom Comparison Engine

See `Matchbox.ComparisonEngine` for information on how to implement a
comparison engine.

For common comparison operations, refer to `Matchbox.CommonComparison`,
which provides a set of standard comparison functions that can be
extended or used as a reference for your own implementations.

#### Configuring Matchbox to use the custom engine:

You can specify your custom engine in the configuration:

```elixir
# config/config.exs
config :matchbox, :comparison_engine, YourApp.ComparisonEngine
```

or you can specify your custom engine in the options at runtime:

```elixir
Matchbox.match_conditions?(123, %{all: :is_integer}, comparison_engine: YourApp.ComparisonEngine)
```

## Documentation

For full API documentation and more examples, visit: [HexDocs](https://hexdocs.pm/matchbox)

## Development & Contribution

We welcome contributions! To set up your development environment:

```sh
# Clone the repository
git clone https://github.com/cylkdev/matchbox.git

# Navigate to the project directory
cd matchbox

# Install dependencies
mix deps.get

# Run tests
mix test
```

To contribute:

  - **Report Issues:** Open an issue for bugs or feature requests.

  - **Submit Pull** Requests: Fork the repo, create a branch, and submit a PR.

  - **Code Style:** Use mix format to maintain Elixir conventions.

## License

Matchbox is released under the [MIT License](https://github.com/cylkdev/matchbox/blob/main/LICENSE).
