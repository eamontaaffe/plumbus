defmodule EventSource.Subscriber do
  @moduledoc """
  A subscriber is a behaviour used to listen in on a store.
  """
  alias EventSource.Fact

  @doc """
  The receive function is called when a new fact is submitted.

  This function will return a status to notify the store of a successful
  retrieval.

  This function will have side effects. The side effects will be used to update
  a model or something. The side effects of this function must be idempotent.
  """
  @callback handle_cast(%Fact{}) :: boolean
end
