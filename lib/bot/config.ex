defmodule Bot.Config do
  use GenServer

  # Client

  def start_link(path) do
    GenServer.start_link(__MODULE__, %{path: path})
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
      encoded_config = File.read!(path)
      read_config = Poison.decode!(encoded_config, keys: :atoms!)
      merge_default_config(read_config)
    else
      config = merge_default_config(%{override: "example2"})
      encoded_config = Poison.encode!(config)
      File.write!(path, encoded_config)
      config
    end
  end

  defp merge_default_config(overrides) do
    defaults = %{
      default: "example",
      override: "i shouldn't see this"
    }
    Map.merge(defaults, overrides)
  end
end
