defmodule Bot do
  @moduledoc """
  Documentation for Bot.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      %{id: Bot.Consumer, start: {Bot.Consumer, :start_link, []}}
    ]

    opts = [
      strategy: :one_for_one,
      name: __MODULE__
    ]

    Supervisor.start_link(children, opts)
  end
end
