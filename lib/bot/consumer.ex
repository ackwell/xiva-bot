defmodule Bot.Consumer do
  use Coxir

  # :MESSAGE_REACTION_REMOVE
  def handle_event({:MESSAGE_REACTION_ADD, reaction}, state) do
    IO.inspect(reaction)
    {:ok, state}
  end

  def handle_event(event, state) do
    Bot.Commands.handle_event(event, state)
  end
end
