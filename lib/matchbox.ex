defmodule Matchbox do
  @moduledoc File.read!("README.md")

  alias Matchbox.ComparisonEngine

  @type subject :: term()
  @type conditions :: map()
  @type resolver :: function()
  @type selector :: {conditions(), resolver()}
  @type selectors :: selector() | list(selector())
  @type opts :: keyword()

  @doc """
  For each `selector`, if `term` matches `conditions` the `fun` is
  applied and the result is returned otherwise `term` is returned
  unchanged.

  ### Options

    * `comparison_engine` - Specifies the comparison engine module.
      Defaults to `Matchbox.CommonComparison`.

    * `:on_change` - Controls if one or all selector are
      applied. When `:cont` all selector are applied.
      When `:halt` only the first matching selector is
      applied. Defaults to `:halt`.

  ### Examples

      # If the term matches, the selector function is applied
      iex> Matchbox.transform("hello", {%{all?: %{===: "hello"}}, &String.upcase/1})
      {"HELLO", true}

      # If the term does not match, it remains unchanged
      iex> Matchbox.transform("world", {%{all?: %{===: "hello"}}, &String.upcase/1})
      {"world", false}
  """
  @spec transform(
          subject :: subject(),
          selectors :: selector() | selectors()
        ) :: {subject :: subject(), matched? :: true | false}
  @spec transform(
          subject :: subject(),
          selectors :: selector() | selectors(),
          opts :: opts()
        ) :: {subject :: subject(), matched? :: true | false}
  def transform(subject, selectors, opts \\ []) do
    selectors
    |> List.wrap()
    |> Enum.reduce_while(subject, &reduce_transform(&1, {&2, false}, opts))
  end

  defp reduce_transform({con, fun}, {subject, matched?}, opts) do
    if matches?(subject, con, opts) do
      subject = if is_function(fun, 1), do: fun.(subject), else: fun.()

      case Keyword.get(opts, :on_change, :halt) do
        :cont -> {:cont, {subject, true}}
        :halt -> {:halt, {subject, true}}
      end
    else
      {:cont, {subject, matched?}}
    end
  end

  @doc """
  Returns `true` if `term` matches `conditions`, otherwise `false`.

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
  @spec matches?(
          subject :: subject(),
          conditions :: conditions()
        ) :: true | false
  @spec matches?(
          subject :: subject(),
          conditions :: conditions(),
          opts :: opts()
        ) :: true | false
  def matches?(subject, con, opts \\ []) do
    if is_list(con) or is_map(con) do
      Enum.any?(con) and eval_con(subject, con, opts)
    else
      eval_con(subject, con, opts)
    end
  end

  defp eval_con(subject, [con | todo], opts) do
    if Enum.any?(todo) do
      eval_con(subject, con, opts) and eval_con(subject, todo, opts)
    else
      eval_con(subject, con, opts)
    end
  end

  defp eval_con(_subject, op, _opts) when op in [:any, :*] do
    true
  end

  defp eval_con(subject, {:all?, con}, opts) do
    Enum.any?(con) and Enum.all?(con, &eval_con(subject, &1, opts))
  end

  defp eval_con(subject, {:any?, con}, opts) do
    Enum.any?(con) and Enum.any?(con, &eval_con(subject, &1, opts))
  end

  defp eval_con(subject, {:not, con}, opts) do
    eval_con(subject, con, opts) === false
  end

  defp eval_con(subject, {key, con} = kv, opts) when is_list(subject) do
    if ComparisonEngine.operator?(key) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      with true <- Keyword.has_key?(subject, key) do
        subject
        |> Keyword.get(key)
        |> eval_con(con, opts)
      end
    end
  end

  defp eval_con(subject, {key, con} = kv, opts) when is_map(subject) do
    if ComparisonEngine.operator?(key) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      with true <- Map.has_key?(subject, key) do
        subject
        |> Map.get(key)
        |> eval_con(con, opts)
      end
    end
  end

  defp eval_con(subject, {key, _con} = kv, opts) do
    if ComparisonEngine.operator?(key, opts) do
      ComparisonEngine.compare?(subject, kv, opts)
    else
      subject === kv
    end
  end

  defp eval_con(subject, con, opts) when is_map(con) do
    eval_con(subject, Map.to_list(con), opts)
  end

  defp eval_con(subject, val, opts) do
    if ComparisonEngine.operator?(val, opts) do
      ComparisonEngine.compare?(subject, val, opts)
    else
      subject === val
    end
  end
end
