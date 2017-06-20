defmodule Plumbus.Store do
  @moduledoc """
  Store's are used to persist events.

  The only way to change the state of the database is to dispatch an event to
  a store.

  The only way to get an event into the database is via the master store. All
  events pass through it.

  ## Behaviours

  ### Publisher

  When a store is updated with a new event, it pushes a notification to all of
  it's subscribers that it's state has changed.

  ### Subscriber

  First and foremost, stores are subscribers to their own updates. When the
  state of the store is updated, a store first checks to see if it needs to
  perform any updates such as spawning a view or a new store.

  Secondly all store's which are not the master store will be subscribed to it's
  parent's updates. When it receives an event from it's parent, it decides if
  it want's to dispatch the event to it's own store or ignore it.

  ### Spawner

  Stores have the ability to spawn child processes. The two types of processes
  it can spawn are stores and views. The child processes are also subscribed to
  any publishing calls from the parent.

  """
end
