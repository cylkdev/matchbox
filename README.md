# Matchbox

Matchbox is an Elixir library that provides a flexible
pattern matching system for structuring and filtering
data. It simplifies writing expressive and declarative
pattern-matching logic, making it easier to manipulate
and query nested data structures.

**Features**

- Flexible pattern matching for complex data structures
- Lightweight and efficient
- Supports Elixir’s native pattern matching enhancements
- Easy-to-use API

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

To understand the benefits of Matchbox lets look at an example where we want to
filter specific data from a list by pattern matching against a nested structure,
one way to solve this in elixir you can do:

```elixir
data = [
  %{status: :inactive, user: %{id: 1, name: "annie"}},
  %{status: :active, user: %{id: 2, name: "bart"}},
  %{status: :active, user: %{id: 3, name: "alice"}}
]

Enum.filter(data, fn elem ->
  elem.status === :active and
  elem.user.id > 1 and
  elem.user.name =~ ~r/^a(.*)/
end)

# result
[%{status: :active, user: %{id: 3, name: "alice"}}]
```

This works fine, is simple and easy to read. Things start to get more complex when this
functionality needs to be shared across other modules or apps which might lead to you
repeating the same code.

Here’s how you can use Matchbox to do the same thing:

```elixir
data = [
  %{status: :inactive, user: %{id: 1, name: "annie"}},
  %{status: :active, user: %{id: 2, name: "bart"}},
  %{status: :active, user: %{id: 3, name: "alice"}}
]

conditions = %{
  all: %{
    status: :active,
    user: %{
      id: %{>: 1},
      name: %{=~: ~r/^a(.*)/}
    }
  }
}

Enum.filter(data, &Matchbox.match_conditions?(&1, conditions))

# result
[%{status: :active, user: %{id: 3, name: "alice"}}]
```

Lets unpack the conditions map for a second and what its saying:

```elixir
%{
  all: %{
    status: :active,
    user: %{
      id: %{>: 1},
      name: %{=~: ~r/^a(.*)/}
    }
  }
}
```

- The word `all` acts as a qualifier. this tells matchbox how to evaluate the conditions.
When the qualifier is all, all expressions in the conditions map must match the term to consider the evaluation true.
however when the qualifier is `any` then only one expression in the conditions map can match the term
to consider the evaluation true.
- The next thing we do is check that the key `status` exists and equals to `:active`
- We then start searching the nested field `user` and the id must be greater than `1` and the `name` must start with the letter `a`

Matchbox is flexible and supports a query-like language with keywords:

```elixir
data = [
  %{status: :inactive, user: %{id: 1, name: "annie"}},
  %{status: :active, user: %{id: 2, name: "bart"}},
  %{status: :active, user: %{id: 3, name: "alice"}}
]

conditions = [
  all: %{status: :active},
  all: %{user: %{id: %{>: 1}}},
  all: %{user: %{name: %{=~: ~r/^a(.*)/}}}
]

Enum.filter(data, &Matchbox.match_conditions?(&1, conditions))

# result
[%{status: :active, user: %{id: 3, name: "alice"}}]
```

For full API documentation and more examples, visit: [HexDocs](https://hexdocs.pm/matchbox)

## Configuration

The following configuration is available:

```elixir
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

## License

Matchbox is released under the [MIT License](https://github.com/cylkdev/matchbox/blob/main/LICENSE).