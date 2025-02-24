# Filtering Collections

Filtering collections is a common task in applications, whether it's
retrieving active users, filtering orders by status, or applying more
complex conditions. Traditionally, filtering requires writing functions
that iterate through data explicitly, but Matchbox simplifies this by
letting you describe the filtering rules declaratively. This approach
makes code more readable, easier to maintain, and less error-prone.

## Simple Filtering

Suppose we have a list of users:

```elixir
users = [
  %{id: 1, name: "Alice", status: :active},
  %{id: 2, name: "Bob", status: :inactive},
  %{id: 3, name: "Charlie", status: :active}
]
```

We want to filter this list so that only active users remain. Without
Matchbox, we might use `Enum.filter/2` like this:

```elixir
Enum.filter(users, fn user -> user.status == :active end)
```

which returns:

```elixir
[
  %{id: 1, name: "Alice", status: :active},
  %{id: 3, name: "Charlie", status: :active}
]
```

While `Enum.filter/2` is effective, it requires defining a filtering
function every time we need to apply conditions. As filtering logic
grows more complex, these inline functions can become verbose and
harder to maintain.

Matchbox offers a declarative approach where instead of writing
functions, we describe the conditions we want to apply.

```elixir
conditions = %{all: %{status: :active}}
```

Now, we apply the filter:

```elixir
Enum.filter(users, &Matchbox.matches?(&1, conditions))
```

which returns:

```elixir
[
  %{id: 1, name: "Alice", status: :active},
  %{id: 3, name: "Charlie", status: :active}
]
```

### Understanding the Condition Map

In Matchbox, conditions are expressed using a map or keyword list.

- The `all` key ensures that all conditions inside it must be met.
- The `{status: :active}` condition means we are only selecting users
  whose status is `:active`.

This allows us to filter data without explicitly defining a filtering
function.

## Complex Filtering

One of the key advantages of Matchbox is that it allows for composable
and expressive filtering conditions. Instead of modifying our filtering
function every time we add a condition, we simply update the condition map.

Suppose we only want active users whose `id` is greater than `1`. We can
modify our condition map:

```elixir
conditions = %{
  all: %{
    status: :active,
    id: %{>: 1}
  }
}
```

Applying this:

```elixir
Enum.filter(users, &Matchbox.matches?(&1, conditions))
```

Now, the result is:

```elixir
[%{id: 3, name: "Charlie", status: :active}]
```

This ensures that only users who are `active` and have an `id` greater
than `1` are included.

## Conclusion

Filtering data is a fundamental operation in many applications. While
`Enum.filter/2` works well for simple cases, Matchbox provides a
declarative way to express filtering conditions, making the code
more readable and easier to extend.

By structuring conditions in a map, you can easily build powerful
filtering logic without manually iterating over collections or modifying
functions. This approach is especially useful for applications where
filters need to be dynamic and configurable.

