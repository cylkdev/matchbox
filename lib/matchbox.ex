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
    with true <- Enum.any?(conditions) do
      Enum.all?(conditions, fn
        {qual, expr} ->
          if qual in [:all, :any] do
            validate_conditions(subject, qual, expr, opts)
          else
            raise ArgumentError,
                  "Expected qualifier to be ':all' or ':any', got: #{inspect(qual)}"
          end

        term ->
          raise ArgumentError, """
          Expected conditions to be an enum with the keys ':all' or ':any'.

          For example:

            - %{all: %{count: 0}}

            - %{any: %{count: 0}}

          got:
          #{inspect(term)}
          """
      end)
    end
  end

  defp validate_conditions(subject, qual, expr, opts) when is_tuple(subject) do
    if is_tuple(expr) do
      # if the type matches treat as an apples-to-apples comparison
      subject = Tuple.to_list(subject)
      expr = Tuple.to_list(expr)

      with true <- Enum.any?(expr),
           true <- length(subject) === length(expr) do
        subject
        |> Stream.with_index()
        |> enum_all_or_any(qual, fn {subject, index} ->
          evaluate(subject, qual, get_in(expr, [Access.at!(index)]), opts)
        end)
      end
    else
      subject
      |> Tuple.to_list()
      |> Enum.map(&match_condition(&1, qual, expr, opts))
      |> enum_all_or_any(qual, &(&1 === true))
    end
  end

  defp validate_conditions(subject, qual, expr, opts) when is_list(subject) do
    cond do
      is_list(expr) and not Keyword.keyword?(expr) ->
        # if the type matches treat as an apples-to-apples comparison
        with true <- Enum.any?(expr),
             true <- length(subject) === length(expr) do
          subject
          |> Stream.with_index()
          |> enum_all_or_any(qual, fn {subject, index} ->
            evaluate(subject, qual, get_in(expr, [Access.at!(index)]), opts)
          end)
        end

      Keyword.keyword?(subject) ->
        match_condition(subject, qual, expr, opts)

      true ->
        subject
        |> Enum.map(&match_condition(&1, qual, expr, opts))
        |> enum_all_or_any(qual, &(&1 === true))
    end
  end

  defp validate_conditions(subject, qual, expr, opts) do
    match_condition(subject, qual, expr, opts)
  end

  defp match_condition(subject, qual, expr, opts) do
    if is_list(expr) or is_map(expr) do
      Enum.any?(expr) and enum_all_or_any(expr, qual, &evaluate(subject, qual, &1, opts))
    else
      evaluate(subject, qual, expr, opts)
    end
  end

  defp evaluate(subject, qual, {key, val} = expr, opts) when is_list(subject) do
    if Keyword.keyword?(subject) do
      case Keyword.get(subject, key) do
        nil -> false
        entry -> match_condition(entry, qual, val, opts)
      end
    else
      enum_all_or_any(subject, qual, &evaluate(&1, qual, expr, opts))
    end
  end

  defp evaluate(subject, qual, {key, val} = expr, opts) when is_map(subject) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.validate?(subject, expr, opts)
    else
      case Map.get(subject, key) do
        nil -> false
        entry -> match_condition(entry, qual, val, opts)
      end
    end
  end

  defp evaluate(subject, _qual, {key, _val} = expr, opts) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.validate?(subject, expr, opts)
    else
      subject === expr
    end
  end

  defp evaluate(subject, _qual, expr, opts) do
    if ComparisonEngine.operator?(expr, opts) do
      ComparisonEngine.validate?(subject, expr, opts)
    else
      subject === expr
    end
  end

  defp enum_all_or_any(subject, :all, fun), do: Enum.all?(subject, fun)
  defp enum_all_or_any(subject, :any, fun), do: Enum.any?(subject, fun)
end
