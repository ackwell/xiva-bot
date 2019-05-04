defmodule Bot.Config do
  use GenServer

  @enforce_keys [:path]
  defstruct [
    :path
  ]

  # Client

  def start_link(path) do
    GenServer.start_link(__MODULE__, %Bot.Config{path: path})
  end

  # Server

  @impl true
  def init(state) do
    config = load_config(state)
    IO.inspect(config)
    {:ok, state}
  end

  # Private api

  defp load_config(%{path: path}) do
    if File.regular?(path) do
      File.read!(path)
    else
      config = "TODO"
      File.write!(path, config)
      config
    end
  end
end
