defmodule Matchbox.CommonComparison do
  @moduledoc """
  Implements the `Matchbox.ComparisonEngine` behaviour, providing a set of
  operators for evaluating conditions on terms.

  This module supports guard-style type checks, numerical and structural
  comparisons, and pattern matching for common Elixir types. It ensures
  consistency across different term evaluations, enabling flexible
  and extensible matching logic.
  """

  @behaviour Matchbox.ComparisonEngine

  @type guard_operator ::
          :is_atom
          | :is_binary
          | :is_boolean
          | :is_float
          | :is_function
          | :is_integer
          | :is_list
          | :is_map
          | :is_map_key
          | :is_nil
          | :is_number
          | :is_pid
          | :is_port
          | :is_reference
          | :is_struct
          | :is_tuple

  @type comparison_operator ::
          :===
          | :!==
          | :>
          | :<
          | :>=
          | :<=
          | :=~

  @type general_operator :: :length

  @type operator :: guard_operator() | comparison_operator() | general_operator()

  @guard_operators ~w(
    is_atom
    is_binary
    is_boolean
    is_float
    is_function
    is_integer
    is_list
    is_map
    is_map_key
    is_nil
    is_number
    is_pid
    is_port
    is_reference
    is_struct
    is_tuple
  )a

  @comparison_operators ~w(
    ===
    !==
    >
    <
    >=
    <=
    =~
  )a

  @general_operators ~w(
    length
    in
  )a

  @operators @guard_operators ++ @comparison_operators ++ @general_operators

  @impl Matchbox.ComparisonEngine
  @doc """
  Returns a list of all supported operators.

  ### Examples

      iex> Matchbox.CommonComparison.operators()
  """
  @spec operators() :: list(operator())
  def operators, do: @operators

  @impl Matchbox.ComparisonEngine
  @doc """
  Checks if the given operator is supported.

  ### Examples

      iex> Matchbox.CommonComparison.operator?(:is_atom)
      true

      iex> Matchbox.CommonComparison.operator?(:non_existing)
      false
  """
  @spec operator?(operator :: atom()) :: true | false
  for operator <- @operators do
    def operator?(unquote(operator)), do: true
  end

  def operator?(_), do: false

  @impl Matchbox.ComparisonEngine
  @doc """
  Evaluates whether `subject` satisfies the given `condition`.

  ## Supported Operators

  ### Type Guards

  These operators check the type or structure of a term:

    - `:is_atom`
    - `:is_binary`
    - `:is_boolean`
    - `:is_float`
    - `:is_function`
    - `:is_integer`
    - `:is_list`
    - `:is_map`
    - `:is_map_key`
    - `:is_nil`
    - `:is_number`
    - `:is_pid`
    - `:is_port`
    - `:is_reference`
    - `:is_struct`
    - `:is_tuple`

  ### Comparison Operators

  These perform value comparisons:

    - `:===`

    - `:>`, `:<`, `:>=`, `:<=`

    - `:=~` (pattern matching for strings and regexes)

    - Special handling for `DateTime`, `NaiveDateTime`, and `Decimal` types.

  ### General Operators

  ### Examples

      iex> Matchbox.CommonComparison.compare?(1, {:===, 1})
      true

      iex> Matchbox.CommonComparison.compare?([1, 2, 3], {:in, 1})
      true

      iex> Matchbox.CommonComparison.compare?("hello", {:=~, ~r/hello/})
      true
  """
  @spec compare?(subject :: term(), expression :: atom() | {atom(), term()}) :: true | false

  # Guard API

  def compare?(term, :is_atom), do: is_atom(term)
  def compare?(term, :is_binary), do: is_binary(term)
  def compare?(term, :is_boolean), do: is_boolean(term)
  def compare?(term, :is_float), do: is_float(term)
  def compare?(term, :is_function), do: is_function(term)
  def compare?(term, {:is_function, arity}), do: is_function(term, arity)
  def compare?(term, :is_integer), do: is_integer(term)
  def compare?(term, :is_list), do: is_list(term)
  def compare?(term, :is_map), do: is_map(term)
  def compare?(term, {:is_map_key, key}), do: is_map_key(term, key)
  def compare?(term, :is_nil), do: is_nil(term)
  def compare?(term, :is_number), do: is_number(term)
  def compare?(term, :is_pid), do: is_pid(term)
  def compare?(term, :is_port), do: is_port(term)
  def compare?(term, :is_reference), do: is_reference(term)
  def compare?(term, :is_struct), do: is_struct(term)
  def compare?(term, {:is_struct, name}), do: is_struct(term, name)
  def compare?(term, :is_tuple), do: is_tuple(term)

  # Comparison API

  def compare?(term, {:===, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) === :eq

  def compare?(term, {:!==, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) !== :eq

  def compare?(term, {:>, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) === :gt

  def compare?(term, {:<, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) === :lt

  def compare?(term, {:>=, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) in [:eq, :gt]

  def compare?(term, {:<=, val}) when is_struct(term, DateTime),
    do: DateTime.compare(term, val) in [:eq, :lt]

  # NaiveDateTime API

  def compare?(term, {:===, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) === :eq

  def compare?(term, {:!==, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) !== :eq

  def compare?(term, {:>, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) === :gt

  def compare?(term, {:<, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) === :lt

  def compare?(term, {:>=, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) in [:eq, :gt]

  def compare?(term, {:<=, val}) when is_struct(term, NaiveDateTime),
    do: NaiveDateTime.compare(term, val) in [:eq, :lt]

  # Decimal API

  if Code.ensure_loaded?(Decimal) do
    def compare?(term, {:===, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) === :eq

    def compare?(term, {:!==, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) !== :eq

    def compare?(term, {:>, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) === :gt

    def compare?(term, {:<, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) === :lt

    def compare?(term, {:>=, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) in [:eq, :gt]

    def compare?(term, {:<=, val}) when is_struct(term, Decimal),
      do: Decimal.compare(term, val) in [:eq, :lt]
  end

  def compare?(term, {:===, val}), do: term === val
  def compare?(term, {:!==, val}), do: term !== val
  def compare?(term, {:>, val}), do: term > val
  def compare?(term, {:<, val}), do: term < val
  def compare?(term, {:>=, val}), do: term >= val
  def compare?(term, {:<=, val}), do: term <= val
  def compare?(term, {:=~, val}), do: term =~ val

  # General API

  def compare?(list, {:in, val}), do: Enum.member?(list, val)

  def compare?(tup, {:length, expr}) when is_tuple(tup) do
    tup |> Tuple.to_list() |> compare?({:length, expr})
  end

  def compare?(list, {:length, {:===, count}}), do: length(list) === count
  def compare?(list, {:length, {:>, count}}), do: length(list) > count
  def compare?(list, {:length, {:<, count}}), do: length(list) < count
  def compare?(list, {:length, {:>=, count}}), do: length(list) >= count
  def compare?(list, {:length, {:<=, count}}), do: length(list) <= count
  def compare?(list, {:length, {:in, range}}), do: length(list) in range
end
