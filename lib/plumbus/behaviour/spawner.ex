defmodule Plumbus.Behaviour.Spawner do
  @moduledoc """
  Spawners are able to create new stores and views.

  All spawners must also be publishers, because when they spawn a new process,
  it is automatically subscribed to it's updates.
  """
end
