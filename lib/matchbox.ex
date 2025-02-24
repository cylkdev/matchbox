defmodule Matchbox do
  @moduledoc File.read!("README.md")

  alias Matchbox.ComparisonEngine

  @doc """
  Transforms `term` if it meets the given expr.

  If `term` matches the specified expr, `fun` is applied;
  otherwise, `term` is returned unchanged.

  ### Options

    * `comparison_engine` - Specifies the comparison engine module (default: `Matchbox.CommonComparison`).

  ### Examples

      # If the term matches, the transformation function is applied
      iex> Matchbox.transform("hello", %{all?: %{===: "hello"}}, &String.upcase/1)
      "HELLO"

      # If the term does not match, it remains unchanged
      iex> Matchbox.transform("world", %{all?: %{===: "hello"}}, &String.upcase/1)
      "world"
  """
  @spec transform(
          subject :: term(),
          expr :: term(),
          fun :: function()
        ) :: term()
  @spec transform(
          subject :: term(),
          expr :: term(),
          fun :: function(),
          opts :: keyword()
        ) :: term()
  def transform(subject, expr, fun, opts \\ []) do
    if matches?(subject, expr, opts) do
      if is_function(fun, 1) do
        fun.(subject)
      else
        fun.()
      end
    else
      subject
    end
  end

  @doc """
  Returns `true` if `term` matches expression, otherwise `false`.

  ### Examples

      # exact match
      iex> Matchbox.matches?("hello", "hello")
      true

      # match on value
      iex> Matchbox.matches?(%{body: "hello"}, %{body: %{=~: "h"}})
      true

      # check if included in list
      iex> Matchbox.matches?([1, 2, 3], %{in: 1})
      true
  """
  @spec matches?(subject :: term(), expr :: term()) :: true | false
  @spec matches?(subject :: term(), expr :: term(), opts :: keyword()) :: true | false
  def matches?(subject, expr, opts \\ []) do
    if is_list(expr) or is_map(expr) do
      Enum.any?(expr) and eval_expr(subject, expr, opts)
    else
      eval_expr(subject, expr, opts)
    end
  end

  defp eval_expr(subject, [expr | todo], opts) do
    if Enum.any?(todo) do
      eval_expr(subject, expr, opts) and eval_expr(subject, todo, opts)
    else
      eval_expr(subject, expr, opts)
    end
  end

  defp eval_expr(_subject, op, _opts) when op in [:any, :*] do
    true
  end

  defp eval_expr(subject, {:all?, expr}, opts) do
    Enum.any?(expr) and Enum.all?(expr, &eval_expr(subject, &1, opts))
  end

  defp eval_expr(subject, {:any?, expr}, opts) do
    Enum.any?(expr) and Enum.any?(expr, &eval_expr(subject, &1, opts))
  end

  defp eval_expr(subject, {:not, expr}, opts) do
    eval_expr(subject, expr, opts) === false
  end

  defp eval_expr(subject, {key, expr} = kv, opts) when is_list(subject) do
    if ComparisonEngine.operator?(key) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      with true <- Keyword.has_key?(subject, key) do
        subject
        |> Keyword.get(key)
        |> eval_expr(expr, opts)
      end
    end
  end

  defp eval_expr(subject, {key, expr} = kv, opts) when is_map(subject) do
    if ComparisonEngine.operator?(key) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      with true <- Map.has_key?(subject, key) do
        subject
        |> Map.get(key)
        |> eval_expr(expr, opts)
      end
    end
  end

  defp eval_expr(subject, {key, _expr} = kv, opts) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      subject === kv
    end
  end

  defp eval_expr(subject, expr, opts) when is_map(expr) do
    eval_expr(subject, Map.to_list(expr), opts)
  end

  defp eval_expr(subject, expr, opts) do
    if ComparisonEngine.operator?(expr, opts) do
      ComparisonEngine.compare?(subject, expr, opts)
    else
      subject === expr
    end
  end
end
