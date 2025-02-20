defmodule Matchbox.Config do
  @moduledoc false

  @app :matchbox

  @doc false
  @spec comparison_engine :: any()
  def comparison_engine, do: Application.get_env(@app, :comparison_engine)
end
