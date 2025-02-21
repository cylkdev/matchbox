defmodule Matchbox do
  @moduledoc File.read!("README.md")

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
    if satisfies?(term, conditions, opts) do
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
      iex> Matchbox.satisfies?("hello", %{all: "hello"})
      true

      # Numeric comparison
      iex> Matchbox.satisfies?(5, %{all: %{>: 3}})
      true

      # List match (any item)
      iex> Matchbox.satisfies?([1, 2, 3], %{any: 1})
      true

      # Map match (nested key)
      iex> Matchbox.satisfies?(%{body: "hello"}, %{all: %{body: "hello"}})
      true
  """
  @spec satisfies?(
          subject :: term(),
          conditions :: map() | keyword()
        ) :: true | false
  @spec satisfies?(
          subject :: term(),
          conditions :: map() | keyword(),
          opts :: keyword()
        ) :: true | false
  def satisfies?(subject, conditions, opts \\ []) do
    Enum.any?(conditions) and validate_conditions(subject, conditions, opts)
  end

  defp validate_conditions(subject, conditions, opts) do
    Enum.all?(conditions, fn
      {qual, con} when qual in [:all, :any] ->
        conditional_check(subject, qual, con, opts)

      term ->
        raise "Expected qualifier to be `:all` or `:any`, got: #{inspect(term)}"
    end)
  end

  defp conditional_check(subject, qual, con, opts) do
    cond do
      is_tuple(subject) ->
        subject
        |> Tuple.to_list()
        |> conditional_check(qual, con, opts)

      is_list(subject) and Keyword.keyword?(subject) ->
        satisfies?(subject, qual, con, opts)

      is_list(subject) ->
        with true <- Enum.any?(subject) do
          subject
          |> Enum.map(fn term -> satisfies?(term, qual, con, opts) end)
          |> apply_qualifier(qual, &(&1 === true))
        end

      true ->
        satisfies?(subject, qual, con, opts)
    end
  end

  defp satisfies?(subject, qual, con, opts) do
    if is_list(con) or is_map(con) do
      apply_qualifier(con, qual, &eval_expr(subject, qual, &1, opts))
    else
      eval_expr(subject, qual, con, opts)
    end
  end

  defp apply_qualifier(subject, :any, fun), do: Enum.any?(subject, fun)
  defp apply_qualifier(subject, :all, fun), do: Enum.all?(subject, fun)

  defp eval_expr(subject, qual, {key, val}, opts) when is_list(subject) do
    cond do
      ComparisonEngine.operator?(key, opts) ->
        ComparisonEngine.validate?(subject, {key, val}, opts)

      Keyword.keyword?(subject) ->
        case Keyword.get(subject, key) do
          nil -> false
          subject -> satisfies?(subject, qual, val, opts)
        end

      true ->
        conditional_check(subject, qual, val, opts)
    end
  end

  defp eval_expr(subject, qual, {key, val}, opts) when is_map(subject) do
    cond do
      ComparisonEngine.operator?(key, opts) ->
        ComparisonEngine.validate?(subject, {key, val}, opts)

      ComparisonEngine.operator?(key, opts) ->
        case Map.get(subject, key) do
          nil -> false
          subject -> ComparisonEngine.validate?(subject, val, opts)
        end

      true ->
        case Map.get(subject, key) do
          nil -> false
          subject -> satisfies?(subject, qual, val, opts)
        end
    end
  end

  defp eval_expr(subject, _qual, {key, val} = tuple, opts) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.validate?(subject, {key, val}, opts)
    else
      subject === tuple
    end
  end

  defp eval_expr(subject, _qual, val, opts) do
    if ComparisonEngine.operator?(val, opts) do
      ComparisonEngine.validate?(subject, val, opts)
    else
      subject === val
    end
  end
end
