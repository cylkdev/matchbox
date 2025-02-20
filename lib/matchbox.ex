defmodule Matchbox do
  @moduledoc """
  Matchbox simplifies comparisons and transformations
  by using structured data.

  Instead of writing multiple `if` or `case` statements,
  you define conditions in a map or keyword list. This
  makes code cleaner, easier to read, and more
  maintainable.

  ## Why Use Matchbox?

  Consider checking the value of a field in a list of maps:

  ```elixir
  iex> Matchbox.match_conditions?([%{message: "hello"}, %{message: "why hello there!"}], %{all: %{message: %{=~: ~r/hello/}}})
  true
  ```

  This eliminates manual iteration and multiple conditionals.

  ## Installation

  Add Matchbox to your `mix.exs` dependencies:

  ```elixir
  def deps do
    [
      {:matchbox, "~> 0.1.0"}
    ]
  end
  ```

  ## How It Works

  Matchbox evaluates comparisons using a **comparison engine**.
  The default engine, `Matchbox.CommonComparison`, supports:

    - Elixir guards (`is_binary/1`, `is_map/1`, etc.)

    - Comparison operators (`===`, `>`, `<`, `=~`, etc.)

  It also allows **qualifiers** for list comparisons:

    - `:all` - Requires all elements to match

    - `:any` - Requires at least one match

  See `Matchbox.CommonComparison` for details.
  """
  alias Matchbox.ComparisonEngine

  @doc """
  Transforms `term` if it meets the given conditions.

  If `term` matches the specified conditions, `transform_fun` is applied;
  otherwise, `term` is returned unchanged.

  ### Options

    * `comparison_engine` - Specifies the comparison engine module (default: `Matchbox.CommonComparison`).

  ### Examples

      # If the term matches, the transformation function is applied
      iex> Matchbox.transform("hello", %{all: "hello"}, &String.upcase/1)
      "HELLO"

      # If the term does not match, it remains unchanged
      iex> Matchbox.transform("world", %{all: "hello"}, &String.upcase/1)
      "world"
  """
  @spec transform(
          term :: term(),
          conditions :: map() | keyword(),
          transform_fun :: function()
        ) :: term()
  @spec transform(
          term :: term(),
          conditions :: map() | keyword(),
          transform_fun :: function(),
          opts :: keyword()
        ) :: term()
  def transform(term, conditions, transform_fun, opts \\ []) do
    if match_conditions?(term, conditions, opts) do
      if is_function(transform_fun, 1) do
        transform_fun.(term)
      else
        transform_fun.()
      end
    else
      term
    end
  end

  @doc """
  Checks if `term` meets the given conditions.

  ## Supported Comparisons

    - **Exact match:** `%{all: "hello"}` ensures all elements equal `"hello"`

    - **Comparison operators:** `%{all: %{> 10}}` checks if all values are greater than `10`

    - **Nested structures:** `%{any: %{topic: "example"}}` checks if any `topic` field equals `"example"`

  Returns `true` if `term` satisfies the conditions, otherwise `false`.

  ### Options

    * `comparison_engine` - Specifies the comparison engine module (default: `Matchbox.CommonComparison`).

  ### Examples

      # Exact match
      iex> Matchbox.match_conditions?("hello", %{all: "hello"})
      true

      # Numeric comparison
      iex> Matchbox.match_conditions?(5, %{all: %{>: 3}})
      true

      # List match (any item)
      iex> Matchbox.match_conditions?([1, 2, 3], %{any: 1})
      true

      # Map match (nested key)
      iex> Matchbox.match_conditions?(%{body: "hello"}, %{all: %{body: "hello"}})
      true
  """
  @spec match_conditions?(
          term :: term(),
          conditions :: map() | keyword()
        ) :: true | false
  @spec match_conditions?(
          term :: term(),
          conditions :: map() | keyword(),
          opts :: keyword()
        ) :: true | false
  def match_conditions?(term, conditions, opts \\ []) do
    Enum.any?(conditions) and validate_conditions(term, conditions, opts)
  end

  defp validate_conditions(term, conditions, opts) do
    Enum.all?(conditions, fn {qual, exprs} ->
      if qual in [:all, :any] do
        validate_conditional_exprs(term, qual, exprs, opts)
      else
        raise "Expected qualifier to be `:all` or `:any`, got: #{inspect(term)}"
      end
    end)
  end

  defp validate_conditional_exprs(term, qual, exprs, opts) do
    cond do
      is_tuple(term) ->
        term
        |> Tuple.to_list()
        |> validate_conditional_exprs(qual, exprs, opts)

      is_list(term) and Keyword.keyword?(term) ->
        term_match_conditions?(term, qual, exprs, opts)

      is_list(term) ->
        with true <- Enum.any?(term) do
          term
          |> Enum.map(fn term -> term_match_conditions?(term, qual, exprs, opts) end)
          |> apply_qualifier(qual, &(&1 === true))
        end

      true ->
        term_match_conditions?(term, qual, exprs, opts)
    end
  end

  defp term_match_conditions?(term, qual, exprs, opts) do
    if is_list(exprs) or is_map(exprs) do
      apply_qualifier(exprs, qual, &eval_expr(term, qual, &1, opts))
    else
      eval_expr(term, qual, exprs, opts)
    end
  end

  defp apply_qualifier(term, :any, fun), do: Enum.any?(term, fun)
  defp apply_qualifier(term, :all, fun), do: Enum.all?(term, fun)

  defp eval_expr(term, qual, {key, exprs}, opts) when is_list(term) do
    cond do
      ComparisonEngine.operator?(key, opts) ->
        ComparisonEngine.satisfies?(term, {key, exprs}, opts)

      Keyword.keyword?(term) ->
        case Keyword.get(term, key) do
          nil -> false
          val -> term_match_conditions?(val, qual, exprs, opts)
        end

      true ->
        validate_conditional_exprs(term, qual, exprs, opts)
    end
  end

  defp eval_expr(term, qual, {key, exprs}, opts) when is_map(term) do
    cond do
      ComparisonEngine.operator?(key, opts) ->
        ComparisonEngine.satisfies?(term, {key, exprs}, opts)

      ComparisonEngine.operator?(key, opts) ->
        case Map.get(term, key) do
          nil -> false
          input_val -> ComparisonEngine.satisfies?(input_val, exprs, opts)
        end

      true ->
        case Map.get(term, key) do
          nil -> false
          val -> term_match_conditions?(val, qual, exprs, opts)
        end
    end
  end

  defp eval_expr(left_term, _qual, {key, exprs} = right_term, opts) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.satisfies?(left_term, {key, exprs}, opts)
    else
      left_term === right_term
    end
  end

  defp eval_expr(left_term, _qual, right_term, opts) do
    if ComparisonEngine.operator?(right_term, opts) do
      ComparisonEngine.satisfies?(left_term, right_term, opts)
    else
      left_term === right_term
    end
  end
end
