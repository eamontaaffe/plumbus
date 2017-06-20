defmodule EventSource.StoreTest do
  use ExUnit.Case, async: true
  doctest EventSource.Store

  alias EventSource.{Store}
  alias Store.{State, Fact}

  #####
  # GenServer Implementation

  describe "stack:" do
    test "empty stack" do
      state = %State{stack: []}
      {:reply, msg, _new_state} = Store.handle_call(:stack, nil, state)
      assert msg == []
    end

    test "non empty stack" do
      state = %State{stack: [
                        %Fact{id: 0, payload: "foo"},
                        %Fact{id: 0, payload: "bar"}
                      ]}
      {:reply, msg, new_state} = Store.handle_call(:stack, nil, state)
      assert msg == [
        %Fact{id: 0, payload: "foo"},
        %Fact{id: 0, payload: "bar"}
      ]
      assert new_state == state, "the state should not change"
    end
  end

  describe "dispatch:" do
    test "fact to empty stack" do
      state = %State{stack: []}
      {:noreply, %State{stack: new_stack}} = Store.handle_cast(
        {:dispatch, "foo"},
        state
      )
      assert new_stack == [%Fact{id: 0, payload: "foo"}]
    end

    test "fact to non empty stack" do
      state = %State{stack: [%Fact{id: 0, payload: "foo"}], id: 1}
      {:noreply, %State{stack: new_stack}} = Store.handle_cast(
        {:dispatch, "bar"}, state)
      assert new_stack == [
        %Fact{id: 0, payload: "foo"},
        %Fact{id: 1, payload: "bar"}
      ]
    end
  end

  describe "integration:" do
    setup do
      {:ok, pid} = GenServer.start_link Store, nil
      [store: pid]
    end

    test "add a subscriber", %{store: store} do
      GenServer.cast store, {
        :dispatch,
        %{type: :subscribe,
          subscriber: self()
        }
      }

      stack = GenServer.call store, :stack
      assert length(stack) == 1, "There should be a new item in the stack"

      subscribers = GenServer.call store, :subscribers
      [last_subscriber | _] = Enum.reverse(subscribers)

      assert last_subscriber == self(), "The new subscriber should be the test"

      # Dispatch a new event to the store, this will be registered as a fact
      GenServer.cast store, {:dispatch, :payload}

      stack = GenServer.call store, :stack
      assert length(stack) == 2, "There should be two events in the stack"

      assert_received {
        :"$gen_cast",
        {:receive, %Fact{id: 1, payload: :payload}}
      }
    end
  end
end
