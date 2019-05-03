defmodule Bot.Consumer do
  use Coxir

  # :MESSAGE_REACTION_REMOVE
  def handle_event({:MESSAGE_REACTION_ADD, reaction}, state) do
    IO.inspect(reaction)
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end
