# Matchbox

Matchbox is an Elixir library that provides flexible and declarative
pattern matching and transformation for complex data structures. Instead
of manually structuring nested pattern matches, Matchbox simplifies
querying and transforming data using a simple API.

The goal of Matchbox is to improve readability, maintainability, and
reduce boilerplate.

## Features

- **Expressive Pattern Matching** – Match nested structures with ease.

- **Data Transformation** – Transform data structures based on specified patterns.

- **Declarative API** – Simple and readable syntax.

- **Composable** – Works well with existing code.

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

### Pattern Matching in Matchbox

Typically, in Elixir, you would match nested structures manually:

```elixir
case data do
  %{user: %{age: 30, name: "Alice"}} -> true
  _ -> false
end
```

With Matchbox, you can express the same logic declaratively:

```elixir
data = %{user: %{age: 30, name: "Alice", city: "Vancouver"}}

conditions = %{all: %{user: %{age: 30, name: "Alice"}}}

Matchbox.match_conditions?(data, conditions)
# => true
```

This approach reduces boilerplate and makes pattern matching easier to manage.

### Transforming Data in Matchbox

Matchbox takes an all-or-nothing approach to data transformation.
This means that the transformation only applies if the entire
condition set matches.

In standard Elixir, transforming data often requires deep merging:

```elixir
Map.merge(data, %{status: "active"})
```

With Matchbox, you can declaratively apply transformations:

```elixir
data = %{user: %{name: "Alice", age: 30}, status: "inactive"}

conditions = %{all: %{status: "inactive"}}

Matchbox.transform(data, conditions, fn data -> %{data | status: "active"} end)
# => %{status: "active", user: %{name: "Alice", age: 30}}
```

If the conditions do not match, no transformation is applied:

```elixir
data = %{user: %{name: "Alice", age: 30}, status: "inactive"}

conditions = %{all: %{name: "Bart"}}

Matchbox.transform(data, conditions, fn data -> %{data | status: "active"} end)
# => %{user: %{name: "Alice", age: 30}, status: "inactive"}
```

## Documentation

For full API documentation and more examples, visit: [HexDocs](https://hexdocs.pm/matchbox)

## Configuration

The following configuration is available:

```elixir
# Use a custom comparison engine instead of the default
config :matchbox, :comparison_engine, YourApp.ComparisonEngine
```

## Development & Contribution

We welcome contributions! To set up your development environment:

Clone the repository:

```sh
git clone https://github.com/cylkdev/matchbox.git
```

Navigate to the project:

```sh
cd matchbox
```

Install dependencies:

```sh
mix deps.get
```

Run tests:

```sh
mix test
```

To contribute:

  - **Report Issues:** Open an issue if you find a bug or have a feature request.

  - **Submit Pull Requests:** Fork the repository, create a new branch, make your changes, and submit a pull request.

  - **Code Style:** Follow Elixir's coding conventions and format your code using mix format.

## License

Matchbox is released under the [MIT License](https://github.com/cylkdev/matchbox/blob/main/LICENSE).
