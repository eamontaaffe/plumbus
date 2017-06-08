defmodule EventSource.StoreTest do
  use ExUnit.Case, async: true
  doctest EventSource.Store

  alias EventSource.Store
  alias Store.{State,Fact}

  #####
  # GenServer Implementation

  describe "stack/0" do
    test "empty stack" do
      state = %State{stack: []}
      {:reply, msg, _new_state} = Store.handle_call(:stack, nil, state)
      assert msg == []
    end

    test "non empty stack" do
      state = %State{stack: [{:foo, "foo"}, {:bar, "bar"}]}
      {:reply, msg, new_state} = Store.handle_call(:stack, nil, state)
      assert msg == [{:foo, "foo"}, {:bar, "bar"}]
      assert new_state == state, "the state should not change"
    end
  end

  describe "dispatch" do
    test "fact to empty stack" do
      state = %State{stack: []}
      {:noreply, %State{stack: new_stack}} = Store.handle_cast(
        {:dispatch, {:foo, "foo"}},
        state
      )
      assert new_stack == [%Fact{id: 0, type: :foo, payload: "foo"}]
    end

    test "fact to non empty stack" do
      state = %State{stack: [%Fact{id: 0, type: :foo, payload: "foo"}], id: 1}
      {:noreply, %State{stack: new_stack}} = Store.handle_cast(
        {:dispatch, {:bar, "bar"}}, state)
      assert new_stack == [
        %Fact{id: 0, type: :foo, payload: "foo"},
        %Fact{id: 1, type: :bar, payload: "bar"}
      ]
    end
  end

  describe "query" do
    test "query with function" do
      state = %State{stack: [{:foo, "foo"}, {:bar, "bar"}]}
      fun = fn(fact) -> elem(fact, 0) == :foo end
      {:reply, msg, new_state} = Store.handle_call(
        {:query, fun},
        nil,
        state
      )
      assert msg == [{:foo, "foo"}]
      assert new_state == state
    end
  end
end
