defmodule Matchbox.ComparisonEngine do
  @moduledoc """
  Defines the required API for adapters.

  A comparison engine is responsible for evaluating whether
  a given value satisfies a specified condition using a set
  of defined operators. This allows Matchbox to support
  flexible and extensible data evaluations.

  ## Creating an Adapter

  To implement a custom comparison engine, a module must
  define the `Matchbox.ComparisonEngine` behaviour and
  implement the required callbacks.

  ```elixir
  defmodule Matchbox.Support.ExampleEngine do
    @behaviour Matchbox.ComparisonEngine

    @impl Matchbox.ComparisonEngine
    def operators, do: [:===]

    @impl Matchbox.ComparisonEngine
    def operator?(:===), do: true
    def operator?(_), do: false

    @impl Matchbox.ComparisonEngine
    def validate?(left, {:===, right}), do: left === right
    def validate?(_, _), do: false
  end
  ```

  The `validate?/2` function in this example checks whether
  the provided value matches the expected value using the
  strict equality (`:===`) operator.

  Unsupported operations return `false`.

  ## Default Comparison Engine

  Matchbox provides a default implementation, `Matchbox.CommonComparison`,
  which supports commonly used operators such as `:===`, `:>`, and `:<`.

  ### Overriding the Default Engine

  You can specify a custom engine at runtime:

  ```elixir
  Matchbox.satisfies?(
    123,
    %{all: :is_integer},
    comparison_engine: Matchbox.Support.ExampleEngine
  )
  ```

  Or configure it globally in `config/config.exs`:

  ```elixir
  # config/config.exs
  config :matchbox, :comparison_engine, Matchbox.Support.ExampleEngine
  ```

  ## Shared Options

    - `comparison_engine:` (optional) – Defines a custom comparison
      engine module to use. Defaults to `Matchbox.CommonComparison`.
  """

  @doc """
  Returns the list of operators supported by the comparison engine.

  ### Examples

  ```elixir
  iex> Matchbox.Support.ExampleEngine.operators()
  [:===]
  ```
  """
  @doc group: "Comparison Engine API"
  @callback operators :: list(operator :: atom())

  @doc """
  Checks if the given key is a recognized operator.

  ### Examples

  ```elixir
  iex> Matchbox.Support.ExampleEngine.operator?(:===)
  true
  ```
  """
  @doc group: "Comparison Engine API"
  @callback operator?(operator :: atom()) :: true | false

  @doc """
  Checks if the given `left` operand satisfies the specified `operator`.

  ### Examples

  ```elixir
  iex> Matchbox.Support.ExampleEngine.validate?("example", {:===, "example"})
  true
  ```
  """
  @doc group: "Comparison Engine API"
  @callback validate?(left :: term(), condition :: term()) :: true | false

  @doc """
  Executes the callback function `operators/0`.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ### Examples

      iex> Matchbox.ComparisonEngine.operators(comparison_engine: Matchbox.Support.ExampleEngine)
      [:===]
  """
  @spec operators :: list()
  @spec operators(opts :: keyword()) :: list()
  def operators(opts \\ []) do
    adapter(opts).operators()
  end

  @doc """
  Executes the callback function `operator?/1`.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ### Examples

      iex> Matchbox.ComparisonEngine.operator?(:===, comparison_engine: Matchbox.Support.ExampleEngine)
      true
  """
  @spec operator?(operator :: atom()) :: true | false
  @spec operator?(operator :: atom(), opts :: keyword()) :: true | false
  def operator?(operator, opts \\ []) do
    adapter(opts).operator?(operator)
  end

  @doc """
  Executes the callback function `validate?/2`.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ## Examples

      iex> Matchbox.ComparisonEngine.validate?(1, {:===, 1}, comparison_engine: Matchbox.Support.ExampleEngine)
      true
  """
  @spec validate?(left :: term(), condition :: term()) :: true | false
  @spec validate?(left :: term(), condition :: term(), opts :: keyword()) :: true | false
  def validate?(left, condition, opts \\ []) do
    adapter(opts).validate?(left, condition)
  end

  defp adapter(opts) do
    opts[:comparison_engine] ||
      Matchbox.Config.comparison_engine() ||
      Matchbox.CommonComparison
  end
end
