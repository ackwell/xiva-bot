defmodule Bot.Commands do
  use Coxir.Commander

  @prefix "|>"

  command ping, do: Message.reply(message, "pong")
end
