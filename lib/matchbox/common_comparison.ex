defmodule Matchbox.CommonComparison do
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
    any
    in
  )a

  @operators @guard_operators ++ @comparison_operators ++ @general_operators

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

  @type general_operator :: :any | :in

  @type operator :: guard_operator() | comparison_operator() | general_operator()

  @impl Matchbox.ComparisonEngine
  @doc """
  Returns a list of all supported operators.

  #### Examples

      iex> Matchbox.CommonComparison.operators()
      [
        :is_atom,
        :is_binary,
        :is_boolean,
        :is_float,
        :is_function,
        :is_integer,
        :is_list,
        :is_map,
        :is_map_key,
        :is_nil,
        :is_number,
        :is_pid,
        :is_port,
        :is_reference,
        :is_struct,
        :is_tuple,
        :===,
        :!==,
        :>,
        :<,
        :>=,
        :<=,
        :=~,
        :any,
        :in
      ]
  """
  @spec operators() :: list(operator())
  def operators, do: @operators

  @impl Matchbox.ComparisonEngine
  @doc """
  Checks if the given operator is supported.

  #### Examples

      iex> Matchbox.CommonComparison.operator?(:is_atom)
      true

      iex> Matchbox.CommonComparison.operator?(:non_existing)
      false
  """
  @spec operator?(operator :: atom()) :: true | false
  def operator?(:is_atom), do: true
  def operator?(:is_binary), do: true
  def operator?(:is_boolean), do: true
  def operator?(:is_float), do: true
  def operator?(:is_function), do: true
  def operator?(:is_integer), do: true
  def operator?(:is_list), do: true
  def operator?(:is_map), do: true
  def operator?(:is_map_key), do: true
  def operator?(:is_nil), do: true
  def operator?(:is_number), do: true
  def operator?(:is_pid), do: true
  def operator?(:is_port), do: true
  def operator?(:is_reference), do: true
  def operator?(:is_struct), do: true
  def operator?(:is_tuple), do: true

  def operator?(:===), do: true
  def operator?(:!==), do: true
  def operator?(:>), do: true
  def operator?(:<), do: true
  def operator?(:>=), do: true
  def operator?(:<=), do: true
  def operator?(:=~), do: true

  def operator?(:any), do: true
  def operator?(:in), do: true

  # fallback
  def operator?(_), do: false

  @impl Matchbox.ComparisonEngine
  @doc """
  Evaluates whether `left` satisfies the given `condition`.

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

  Other operators for flexible matching:

    - `:any` - Always returns true.

    - `:in` - Checks membership in lists or ranges.

  ### Examples

      iex> Matchbox.CommonComparison.satisfies?(1, {:===, 1})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:in, [1, 2, 3]})
      true

      iex> Matchbox.CommonComparison.satisfies?("hello", {:=~, ~r/hello/})
      true
  """
  @spec satisfies?(left :: term(), condition :: atom() | {atom(), term()}) :: true | false
  def satisfies?(term, :is_atom), do: is_atom(term)
  def satisfies?(term, :is_binary), do: is_binary(term)
  def satisfies?(term, :is_boolean), do: is_boolean(term)
  def satisfies?(term, :is_float), do: is_float(term)
  def satisfies?(term, :is_function), do: is_function(term)
  def satisfies?(term, {:is_function, arity}), do: is_function(term, arity)
  def satisfies?(term, :is_integer), do: is_integer(term)
  def satisfies?(term, :is_list), do: is_list(term)
  def satisfies?(term, :is_map), do: is_map(term)
  def satisfies?(term, {:is_map_key, key}), do: is_map_key(term, key)
  def satisfies?(term, :is_nil), do: is_nil(term)
  def satisfies?(term, :is_number), do: is_number(term)
  def satisfies?(term, :is_pid), do: is_pid(term)
  def satisfies?(term, :is_port), do: is_port(term)
  def satisfies?(term, :is_reference), do: is_reference(term)
  def satisfies?(term, :is_struct), do: is_struct(term)
  def satisfies?(term, {:is_struct, name}), do: is_struct(term, name)
  def satisfies?(term, :is_tuple), do: is_tuple(term)

  # DateTime API

  def satisfies?(left, {:===, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) === :eq

  def satisfies?(left, {:!==, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) !== :eq

  def satisfies?(left, {:>, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) === :gt

  def satisfies?(left, {:<, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) === :lt

  def satisfies?(left, {:>=, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) in [:eq, :gt]

  def satisfies?(left, {:<=, right}) when is_struct(left, DateTime),
    do: DateTime.compare(left, right) in [:eq, :lt]

  # NaiveDateTime API

  def satisfies?(left, {:===, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) === :eq

  def satisfies?(left, {:!==, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) !== :eq

  def satisfies?(left, {:>, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) === :gt

  def satisfies?(left, {:<, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) === :lt

  def satisfies?(left, {:>=, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) in [:eq, :gt]

  def satisfies?(left, {:<=, right}) when is_struct(left, NaiveDateTime),
    do: NaiveDateTime.compare(left, right) in [:eq, :lt]

  # Decimal API

  if Code.ensure_loaded?(Decimal) do
    def satisfies?(left, {:===, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) === :eq

    def satisfies?(left, {:!==, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) !== :eq

    def satisfies?(left, {:>, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) === :gt

    def satisfies?(left, {:<, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) === :lt

    def satisfies?(left, {:>=, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) in [:eq, :gt]

    def satisfies?(left, {:<=, right}) when is_struct(left, Decimal),
      do: Decimal.compare(left, right) in [:eq, :lt]
  end

  def satisfies?(left, {:===, right}), do: left === right
  def satisfies?(left, {:!==, right}), do: left !== right
  def satisfies?(left, {:>, right}), do: left > right
  def satisfies?(left, {:<, right}), do: left < right
  def satisfies?(left, {:>=, right}), do: left >= right
  def satisfies?(left, {:<=, right}), do: left <= right
  def satisfies?(left, {:=~, right}), do: left =~ right

  def satisfies?(_left, :any), do: true
  def satisfies?(left, {:in, right}), do: Enum.member?(left, right)

  # fallback
  def satisfies?(_, _), do: false
end
