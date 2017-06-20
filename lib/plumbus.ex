defmodule Plumbus do
  @moduledoc """
  Plumbus revolves around three main modules:
  1. Events - The communication system.
  2. Stores - The persistence system.
  3. Views - The query system.

  ## Rules

  ### Rule #1

  > The only way to change the state of the application is through an event.

  All events are dispatched to a single master store. The order of events is
  strongly tied to the order they occurred.

  ### Rule #2

  > The only way to view the state of the application is through a view.

  Queries are only able to read from views. Views are nth order extrapolations
  of what is in the master store.

  ## Interactions

  1. Events are dispatched only to the master store.
  2. Stores publish newly received events **after** persisting them themselves.
  3. Stores subscribe to their own events and may spawn child stores and views
     accordingly.
  4. Stores and views are subscribed to the store that spawned them.
  5. The only way to publicly query the database is via a view.

  """
end
