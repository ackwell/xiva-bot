defmodule Bot.Consumer do
  use Coxir

  # :MESSAGE_REACTION_REMOVE
  @impl true
  def handle_event({:MESSAGE_REACTION_ADD, reaction}, state) do
    emoji = reaction.emoji.id || reaction.emoji.name
    role = Bot.Config.ReactionRole.get_role(emoji)

    IO.inspect(role)

    {:ok, state}
  end

  @impl true
  def handle_event(event, state) do
    Bot.Commands.handle_event(event, state)
  end
end
