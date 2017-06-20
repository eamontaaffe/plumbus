defmodule EventSource.Store do
  @moduledoc """
  The persistence of events.
  """
  use GenServer

  alias EventSource.Store.Fact
  # alias EventSource.Subscriber

  @vsn 0
  defmodule State do
    @moduledoc"""
    Represents the current state of the store.
    """
    defstruct stack: [], id: 0, subscribers: []
  end

  #####
  # Exteral API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  #####
  # GenServer implementation
  def init(_args) do
    {:ok, %State{subscribers: [self()]}}
  end

  def handle_cast({:dispatch, payload}, state) do
    fact = %Fact{id: state.id, payload: payload}
    notify_subscribers(state.subscribers, fact)
    {:noreply, %{state | stack: state.stack ++ [fact], id: state.id + 1}}
  end

  # Notify all of the subscribers about the most recently received fact
  defp notify_subscribers(subscribers, fact) do
    for subscriber <- subscribers do
      # Assume subscribers use the subscriber behaviour
      GenServer.cast subscriber, {:receive, fact}
    end
  end

  def handle_call(:stack, _from, state) do
    {:reply, state.stack, state}
  end

   def handle_call(:subscribers, _from, state) do
    {:reply, state.subscribers, state}
  end

  @doc """
  The store itself is a subscriber to it's own updates.

  This function should only be triggered by the store itself.
  """
  def handle_cast({:receive, fact}, state) do
    # Check that the call is coming from this genserver process
    # assert from == self

    case fact do
      # Do something interesting with the fact if necessary
      %Fact{id: _id, payload: %{type: :subscribe, subscriber: subscriber}} ->
        {:noreply, %{state | subscribers: state.subscribers ++ [subscriber]}}
      _ ->
        {:noreply, state}
    end
  end
end
