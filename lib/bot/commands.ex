defmodule Bot.Commands do
  use Coxir.Commander
  import Coxir.Commander.Utils

  @prefix "|> "

  @permit &is_admin?/2
  command set_reaction(arguments) do
    result =
      with [message_id, emoji, role | _rest] <- String.split(arguments),
           {:ok, role_id} <- role_id(role) do
        emoji_id =
          case custom_emoji_id(emoji) do
            {:incorrect} -> emoji
            {:ok, id} -> id
          end

        Bot.Config.ReactionRole.set(message_id, emoji_id, role_id)

        :ok
      end

    case result do
      :ok -> respond_success(message)
      _ -> respond_fail(message)
    end
  end

  defp respond_success(message) do
    Message.react(message, "✅")
  end

  defp respond_fail(message) do
    Message.react(message, "❌")
  end

  defp role_id(format) do
    first_group(Regex.run(~r/<@&(\d+)>/, format))
  end

  defp custom_emoji_id(format) do
    first_group(Regex.run(~r/<a?:.+:(\d+)>/, format))
  end

  defp first_group(nil), do: {:incorrect}
  defp first_group([_match, group]), do: {:ok, group}
end
