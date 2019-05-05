defmodule Bot.Consumer do
  use Coxir

  # :MESSAGE_REACTION_REMOVE
  @impl true
  def handle_event({:MESSAGE_REACTION_ADD, reaction}, state) do
    emoji = reaction.emoji.id || reaction.emoji.name
    role = Bot.Config.ReactionRole.get_role(reaction.message_id, emoji)

    if role do
      member = Member.get(reaction.guild_id, reaction.user_id)
      Member.add_role(member, role)
    end

    {:ok, state}
  end

  @impl true
  def handle_event(event, state) do
    Bot.Commands.handle_event(event, state)
  end
end
