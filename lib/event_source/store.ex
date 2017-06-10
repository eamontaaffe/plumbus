defmodule EventSource.Store do
  @moduledoc """
  The persistence of events.
  """
  use GenServer

  @vsn 0
  defmodule State do
    @moduledoc"""
    Represents the current state of the store.
    """
    defstruct stack: [], id: 0, indexs: %{}
  end

  @vsn 0
  defmodule Fact do
    @moduledoc"""
    Represents an event or a "fact" as Greg Young would phrase it.
    """
    defstruct id: -1, payload: %{}
  end

  @vsn 0
  defmodule IndexFact do
    @moduledoc"""
    A special type of fact which is used to modify the store's indexs.
    """
    defstruct name: nil, filter: nil, stacks: %{}
  end

  #####
  # Exteral API

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # def dispatch(event) do
  #   GenServer.cast __MODULE__, {:dispatch, event}
  # end

  # def stack() do
  #   GenServer.call __MODULE__, :stack
  # endq

  # def stack(query) do
  #   GenServer.call __MODULE__, {:stack, query}
  # end

  #####
  # GenServer implementation

  def init(_args) do
    {:ok, %State{stack: []}}
  end

  def handle_cast({:dispatch, payload}, state) do
    event = %Fact{id: state.id, payload: payload}
    {:noreply, %{state | stack: state.stack ++ [event], id: state.id + 1}}
  end

  def handle_call(:stack, _from, state) do
    {:reply, state.stack, state}
  end

  def handle_call({:query, query}, _from, state) do
    result = Enum.filter(state.stack, query)
    {:reply, result, state}
  end

  @vsn 0
  defmodule Index do
    @moduledoc"""
    A special type of fact which is used to modify the store's indexs.
    """
    defstruct name: nil, filter: nil, stacks: %{}
  end

  @doc"""
  An index creates new stacks based on a return value of the sort function. Each
  distinct output value gets its own new stack.

  ```elixir
  stack = [%Fact{id: 0, payload: 1}, %Fact{id: 1, payload: 2},
    %Fact{id: 2, payload: 1}]
  filter = fn (fact) -> fact.payload end
  Store.handle_cast({:register_index, :idx, filter}, %State{stack: stack})
  ```
  This will create an index called `:idx` which will distribute the current
  stack into two sub stacks:

  ```elixir
  idx:1 = [%Fact{id: 0, payload: 1}, %Fact{id: 3, payload: 1}]
  idx:2 = [%Fact{id: 1, payload: 2}]
  ```

  The sub stacks are also sorted in the order that the events occured.
  """
  def handle_call({:index, name, value}, _from, state) do
    sub_stack =
      state.indexs
      |> Map.get(name)
      |> Map.get(value)
    {:reply, sub_stack, state}
  end

  def handle_cast({:register_index, name, filter}, state) do
    new_state = %{state | indexs: Map.put(
                     state.indexs, name, %Index{filter: filter})}
    {:noreply, new_state}
  end

  def handle_cast({:initialize_index, name}, state) do
    new_indexs = Map.update!(state.indexs, name, fn (index) ->
      stacks = Enum.reduce(state.stack, %{}, fn(fact, acc) ->
      key = index.filter.(fact)
      Map.put(
        acc,
        key,
        Map.get(acc, key, []) ++ [fact])
      end)
      %{index | stacks: stacks}
    end)

    new_state = %{state | indexs: new_indexs}
    {:noreply, new_state}
  end
end
