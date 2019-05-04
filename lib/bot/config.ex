defmodule Bot.Config do
  use GenServer

  # Client

  def start_link(path) do
    GenServer.start_link(__MODULE__, %{path: path}, name: Bot.Config)
  end

  defmodule ReactionRole do
    def set(emoji_id, role_id) do
      GenServer.call(Bot.Config, {
        :reaction_role,
        :set,
        %{emoji_id: emoji_id, role_id: role_id}
      })
    end

    def get_role(emoji_id) do
      GenServer.call(Bot.Config, {:reaction_role, :get_role, emoji_id})
    end
  end

  # Server

  @impl true
  def init(state) do
    config = load_config(state)
    {:ok, Map.merge(state, %{config: config})}
  end

  @impl true
  def handle_call({:reaction_role, :set, reaction_role}, _from, state) do
    state = put_in(
      state.config.reaction_roles,
      [reaction_role | state.config.reaction_roles]
    )
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:reaction_role, :get_role, emoji_id}, _from, state) do
    reaction_role = Enum.find(
      state.config.reaction_roles,
      &(&1.emoji_id == emoji_id)
    )
    {:reply, reaction_role.role_id, state}
  end

  # Private api

  defp load_config(%{path: path}) do
    if File.regular?(path) do
      encoded_config = File.read!(path)
      read_config = Poison.decode!(encoded_config, keys: :atoms!)
      merge_default_config(read_config)
    else
      config = merge_default_config(%{})
      encoded_config = Poison.encode!(config)
      File.write!(path, encoded_config)
      config
    end
  end

  defp merge_default_config(overrides) do
    defaults = %{
      reaction_roles: []
    }

    Map.merge(defaults, overrides)
  end
end
