defmodule EventSource.Fact do
  @moduledoc """
  Fact's are the unit of currency in a stack.

  > Event Sourcing says all state is transient and you only store facts.

  - Greg Young

  There are a few special types of Fact's which are used by the system to build
  the storage outputs. But all user created facts are of the base type `Fact`
  """
  defstruct id: -1, payload: nil
end
