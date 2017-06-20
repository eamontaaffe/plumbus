defmodule Plumbus.View do
  @moduledoc """
  Views are used to inspect the state of the database.

  The only way to observe the state of the database is via a view.

  Generally views are used to organize events into a format that is easy to read
  for whatever is querying it. There are not immutable, but rather update thier
  attributes to reflect the combination of all events which have been dispatched
  to it prior.

  ## Behaviours

  ### Subscriber

  Views are spawned as children of stores which are publishers of events. When
  a views parent publishes an event, the view is notified. It has the ability to
  ignore the event, or update it's state accordingly.

  ### Query-able

  Views are able to be read via a public API. Their state is able to be read
  but not mutated by anyone with access to the application.

  """
end
