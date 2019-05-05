defmodule Bot.Consumer do
  use Coxir

  # :MESSAGE_REACTION_REMOVE
  def handle_event({:MESSAGE_REACTION_ADD, reaction}, state) do
    role = get_reaction_role(reaction)
    if role do
      member = Member.get(reaction.guild_id, reaction.user_id)
      Member.add_role(member, role)
    end

    {:ok, state}
  end

  def handle_event({:MESSAGE_REACTION_REMOVE, reaction}, state) do
    role = get_reaction_role(reaction)
    if role do
      member = Member.get(reaction.guild_id, reaction.user_id)
      Member.remove_role(member, role)
    end

    {:ok, state}
  end

  # Fall back to commander handler
  def handle_event(event, state) do
    Bot.Commands.handle_event(event, state)
  end

  defp get_reaction_role(reaction) do
    emoji = reaction.emoji.id || reaction.emoji.name
    Bot.Config.ReactionRole.get_role(reaction.message_id, emoji)
  end
end
