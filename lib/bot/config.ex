defmodule Bot.Config do
  use GenServer

  # Client

  def start_link(path) do
    GenServer.start_link(__MODULE__, %{path: path}, name: Bot.Config)
  end

  defmodule ReactionRole do
    @derive [Poison.Encoder]
    defstruct [:message, :emoji, :role]

    def set(message, emoji, role) do
      GenServer.call(Bot.Config, {
        :reaction_role,
        :set,
        %ReactionRole{message: message, emoji: emoji, role: role}
      })

      GenServer.cast(Bot.Config, :save)
    end

    def get_role(message, emoji) do
      GenServer.call(Bot.Config, {:reaction_role, :get_role, message, emoji})
    end
  end

  # Server

  @impl true
  def init(state) do
    config = load_config(state.path)
    {:ok, Map.merge(state, %{config: config})}
  end

  @impl true
  def handle_call({:reaction_role, :set, reaction_role}, _from, state) do
    %{reaction_roles: reaction_roles} = state.config

    reaction_roles =
      [reaction_role | reaction_roles]
      |> Enum.uniq_by(fn %{message: message, emoji: emoji} -> {message, emoji} end)

    state = put_in(state.config.reaction_roles, reaction_roles)

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:reaction_role, :get_role, message, emoji}, _from, state) do
    reaction_role =
      Enum.find(
        state.config.reaction_roles,
        &({&1.message, &1.emoji} == {message, emoji})
      )

    {:reply, reaction_role && reaction_role.role, state}
  end

  @impl true
  def handle_cast(:save, state) do
    write_config(state.path, state.config)
    {:noreply, state}
  end

  # Private api

  defp load_config(path) do
    if File.regular?(path) do
      merge_default_config(read_config(path))
    else
      config = merge_default_config(%{})
      write_config(path, config)
      config
    end
  end

  defp read_config(path) do
    encoded_config = File.read!(path)

    Poison.decode!(encoded_config,
      as: %{"reaction_roles" => [%ReactionRole{}]}
    )
    |> Enum.map(fn {key, value} -> {String.to_existing_atom(key), value} end)
    |> Enum.into(%{})
  end

  defp write_config(path, config) do
    encoded_config = Poison.encode!(config)
    File.write!(path, encoded_config)
  end

  defp merge_default_config(overrides) do
    defaults = %{
      reaction_roles: []
    }

    Map.merge(defaults, overrides)
  end
end
