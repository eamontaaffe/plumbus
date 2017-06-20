defmodule Plumbus.Event do
  @moduledoc """
  An event is the communication currency of Plumbus.

  It is a passive struct which is passed around by views and stores which used
  it to update the state of the application.
  """
  @enforce_keys [:payload]
  defstruct [:payload]
end
