defmodule EventSource.Store do
  use GenServer

  @vsn 0
  defmodule State do
    defstruct stack: [], id: 0
  end

  @vsn 0
  defmodule Fact do
    defstruct id: -1, type: "", payload: %{}
  end

  #####
  # Exteral API

  def start_link() do
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

  def handle_cast({:dispatch, {type, payload}}, state) do
    event = %Fact{ id: state.id, type: type, payload: payload}
    {:noreply, %{state | stack: state.stack ++ [event], id: state.id + 1}}
  end

  def handle_call(:stack, _from, state) do
    {:reply, state.stack, state}
  end

  def handle_call({:query, query}, _from, state) do
    result = Enum.filter(state.stack, query)
    {:reply, result, state}
  end
end
