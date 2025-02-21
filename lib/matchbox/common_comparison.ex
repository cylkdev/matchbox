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
  Implements the `Matchbox.ComparisonEngine` behaviour.

  This module defines common operators for performing guard checks and comparisons
  on terms, enabling flexible and extensible matching logic.

  ## Operators

  The following operators are available:

  ### Guard operators

  The (operators)[https://hexdocs.pm/elixir/1.12.3/Kernel.html#module-guards] check the type or structure of a given term:

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

  ### Comparison operators

  These operators perform direct comparisons between terms:

    - `:===`
    - `:>`
    - `:<`
    - `:>=`
    - `:<=`
    - `:=~`

  ### General Operators

  These operators perform specific comparisons between terms:

      - `:any`
      - `:in`
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
  Returns the list of supported operators.

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
  Returns `true` if `key` is a recognized operator, otherwise `false`.

  #### Examples

      iex> Matchbox.CommonComparison.operator?(:non_existing)
      false

      iex> Matchbox.CommonComparison.operator?(:is_atom)
      true

      iex> Matchbox.CommonComparison.operator?(:is_binary)
      true

      iex> Matchbox.CommonComparison.operator?(:is_boolean)
      true

      iex> Matchbox.CommonComparison.operator?(:is_float)
      true

      iex> Matchbox.CommonComparison.operator?(:is_function)
      true

      iex> Matchbox.CommonComparison.operator?(:is_integer)
      true

      iex> Matchbox.CommonComparison.operator?(:is_list)
      true

      iex> Matchbox.CommonComparison.operator?(:is_map)
      true

      iex> Matchbox.CommonComparison.operator?(:is_nil)
      true

      iex> Matchbox.CommonComparison.operator?(:is_number)
      true

      iex> Matchbox.CommonComparison.operator?(:is_pid)
      true

      iex> Matchbox.CommonComparison.operator?(:is_port)
      true

      iex> Matchbox.CommonComparison.operator?(:is_reference)
      true

      iex> Matchbox.CommonComparison.operator?(:is_struct)
      true

      iex> Matchbox.CommonComparison.operator?(:is_tuple)
      true

      iex> Matchbox.CommonComparison.operator?(:===)
      true

      iex> Matchbox.CommonComparison.operator?(:!==)
      true

      iex> Matchbox.CommonComparison.operator?(:<)
      true

      iex> Matchbox.CommonComparison.operator?(:>)
      true

      iex> Matchbox.CommonComparison.operator?(:<=)
      true

      iex> Matchbox.CommonComparison.operator?(:>=)
      true

      iex> Matchbox.CommonComparison.operator?(:=~)
      true

      iex> Matchbox.CommonComparison.operator?(:any)
      true

      iex> Matchbox.CommonComparison.operator?(:in)
      true
  """
  @spec operator?(key :: atom()) :: true | false
  def operator?(:any), do: true
  def operator?(:in), do: true

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

  # fallback
  def operator?(_), do: false

  @impl Matchbox.ComparisonEngine
  @doc """
  Returns the result of comparing the `left` term by `operator`.

  #### Examples

      iex> Matchbox.CommonComparison.satisfies?("hello", {:=~, ~r|hello|})
      true

      iex> Matchbox.CommonComparison.satisfies?(:matchbox, :is_atom)
      true

      iex> Matchbox.CommonComparison.satisfies?("matchbox", :is_binary)
      true

      iex> Matchbox.CommonComparison.satisfies?(false, :is_boolean)
      true

      iex> Matchbox.CommonComparison.satisfies?(1.0, :is_float)
      true

      iex> Matchbox.CommonComparison.satisfies?(fn -> :ok end, :is_function)
      true

      iex> Matchbox.CommonComparison.satisfies?(fn _ -> :ok end, {:is_function, 1})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, :is_integer)
      true

      iex> Matchbox.CommonComparison.satisfies?([], :is_list)
      true

      iex> Matchbox.CommonComparison.satisfies?(%{}, :is_map)
      true

      iex> Matchbox.CommonComparison.satisfies?(%{body: "hello"}, {:is_map_key, :body})
      true

      iex> Matchbox.CommonComparison.satisfies?(nil, :is_nil)
      true

      iex> Matchbox.CommonComparison.satisfies?(12.34, :is_number)
      true

      iex> Matchbox.CommonComparison.satisfies?(IEx.Helpers.pid("0.0.0"), :is_pid)
      true

      iex> Matchbox.CommonComparison.satisfies?(Kernel.make_ref(), :is_reference)
      true

      iex> Matchbox.CommonComparison.satisfies?(%Matchbox.Support.ExampleStruct{}, :is_struct)
      true

      iex> Matchbox.CommonComparison.satisfies?(%Matchbox.Support.ExampleStruct{}, {:is_struct, Matchbox.Support.ExampleStruct})
      true

      iex> Matchbox.CommonComparison.satisfies?({1, 2, 3}, :is_tuple)
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:===, 1})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:!==, 2})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:>, 0})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:<, 2})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:>=, 1})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:<=, 1})
      true

      iex> Matchbox.CommonComparison.satisfies?(1, :any)
      true

      iex> Matchbox.CommonComparison.satisfies?(1, {:in, [1, 2, 3]})
      true
  """
  @spec satisfies?(left :: term(), right :: term()) :: true | false
  def satisfies?(_left, :any), do: true
  def satisfies?(left, {:in, right}), do: left in right

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

  def satisfies?(left, {:===, right}), do: left === right
  def satisfies?(left, {:!==, right}), do: left !== right
  def satisfies?(left, {:>, right}), do: left > right
  def satisfies?(left, {:<, right}), do: left < right
  def satisfies?(left, {:>=, right}), do: left >= right
  def satisfies?(left, {:<=, right}), do: left <= right
  def satisfies?(left, {:=~, right}), do: left =~ right

  # fallback
  def satisfies?(_, _), do: false
end
