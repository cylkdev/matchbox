defmodule Matchbox.ComparisonEngine do
  @moduledoc """
  Defines the API required for adapters.

  Engines define supported operators and implement logic
  to evaluate whether a given operation is satisfied.

  ## Creating an Adapter

  To create a custom engine adapter, implement the `Matchbox.ComparisonEngine`
  behaviour and define the required callback functions:

  ```elixir
  defmodule MyCustomEngine do
    @behaviour Matchbox.ComparisonEngine

    @impl Matchbox.ComparisonEngine
    def operators do
      [:===, :!=, :>, :<]
    end

    @impl Matchbox.ComparisonEngine
    def operator?(key) do
      key in operators()
    end

    @impl Matchbox.ComparisonEngine
    def satisfies?(left, {:===, right}), do: left === right
    def satisfies?(left, {:!=, right}), do: left != right
    def satisfies?(left, {:>, right}), do: left > right
    def satisfies?(left, {:<, right}), do: left < right
    def satisfies?(_, _), do: false
  end
  ```

  Then, use your custom engine by specifying it in the options:

  ```elixir
  Matchbox.ComparisonEngine.operators(engine: MyCustomEngine)
  Matchbox.ComparisonEngine.operator?(:===, engine: MyCustomEngine)
  Matchbox.ComparisonEngine.satisfies?(5, :>, 3, engine: MyCustomEngine)
  ```

  ## Shared Options

    * `comparison_engine` - The module responsible for custom comparisons, such as guard-based checks.

        This option is resolved as follows:

        - An attempt is made to get the module from the option `:comparison_engine`.
        - If the option value is `nil` an attempt is made to get the module from the configuration
          option `:comparison_engine` (e.g. `config :matchbox, :comparison_engine, YourApp.ComparisonEngine`)
        - If the configuration option is `nil` it defaults to `Matchbox.CommonComparison`.
  """

  @doc """
  Returns a list of operators supported by the comparison engine.

  Implementing modules must define this function.

  ### Examples

      iex> Matchbox.Support.ExampleEngine.operators()
      [:===]
  """
  @callback operators :: list()

  @doc """
  Returns `true` if the given `key` is a recognized operator otherwise `false`.

  Implementing modules must define this function.

  ### Examples

      iex> Matchbox.Support.ExampleEngine.operator?(:===)
      true
  """
  @callback operator?(key :: term()) :: true | false

  @doc """
  Checks if the given `left` operand satisfies the specified `operator`.

  Implementing modules must define this function.

  ### Examples

      iex> Matchbox.Support.ExampleEngine.satisfies?("example", {:===, "example"})
      true
  """
  @callback satisfies?(left :: term(), right :: term()) :: true | false

  @doc """
  Returns the list of operators supported by the specified engine.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ### Examples

      iex> Matchbox.ComparisonEngine.operators(comparison_engine: Matchbox.Support.ExampleEngine)
      [:===]
  """
  @spec operators :: list()
  @spec operators(opts :: keyword()) :: list()
  def operators(opts \\ []) do
    engine!(opts).operators()
  end

  @doc """
  Checks if the given `key` is a recognized operator in the specified engine.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ### Examples

      iex> Matchbox.ComparisonEngine.operator?(:===, engine: Matchbox.Support.ExampleEngine)
      true
  """
  @spec operator?(key :: term()) :: true | false
  @spec operator?(key :: term(), opts :: keyword()) :: true | false
  def operator?(key, opts \\ []) do
    engine!(opts).operator?(key)
  end

  @doc """
  Evaluates whether the given `left` operand satisfies the specified `operator`.

  ### Options

  See the "Shared Options" section in the module documentation for options.

  ## Examples

      iex> Matchbox.ComparisonEngine.satisfies?(1, {:===, 1}, engine: Matchbox.Support.ExampleEngine)
      true
  """
  @spec satisfies?(left :: term(), right :: term()) :: true | false
  @spec satisfies?(left :: term(), right :: term(), opts :: keyword()) :: true | false
  def satisfies?(left, right, opts \\ []) do
    engine!(opts).satisfies?(left, right)
  end

  defp engine!(opts) do
    opts[:comparison_engine] || Matchbox.Config.comparison_engine() || Matchbox.CommonComparison
  end
end
