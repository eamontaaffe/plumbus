defmodule EventSource.StoreTest do
  use ExUnit.Case, async: true
  doctest EventSource.Store

  alias EventSource.Store
  alias Store.{State,Fact,Index}

  #####
  # GenServer Implementation

  describe "stack/0" do
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

  describe "dispatch" do
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

  describe "index" do
    test "get" do
      indexs = %{
        idx: %{
          1 => [%Fact{id: 0, payload: 1}, %Fact{id: 3, payload: 1}],
          2 => [%Fact{id: 1, payload: 2}]
        },
      }
      state = %State{indexs: indexs}
      {:reply, idx1, _state} = Store.handle_call({:index, :idx, 1}, nil, state)
      assert idx1 == [%Fact{id: 0, payload: 1}, %Fact{id: 3, payload: 1}]
    end

    test "register" do
      filter = fn (fact) -> fact.payload end

      {:noreply, new_state} = Store.handle_cast(
        {:register_index, :idx, filter}, %State{})

      assert new_state == %State{indexs: %{idx: %Index{filter: filter}}}
    end

    test "initialize" do
      stack = [%Fact{id: 0, payload: 1}, %Fact{id: 1, payload: 2},
               %Fact{id: 2, payload: 1}]
      filter = fn (fact) -> fact.payload end
      state = %State{stack: stack, indexs: %{idx: %Index{filter: filter}}}

      {:noreply, new_state} = Store.handle_cast(
        {:initialize_index, :idx}, state)

      assert Map.get(new_state.indexs, :idx).stacks == %{
        1 => [%Fact{id: 0, payload: 1}, %Fact{id: 2, payload: 1}],
        2 => [%Fact{id: 1, payload: 2}]
      }
    end
  end
end
