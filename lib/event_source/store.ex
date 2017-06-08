defmodule EventSource.Store do
  use GenServer

  @vsn "0"
  defmodule State do
    defstruct stack: []
  end

  #####
  # Exteral API

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def dispatch(event) do
    GenServer.cast __MODULE__, {:dispatch, event}
  end

  def stack() do
    GenServer.call __MODULE__, :stack
  end

  def stack(query) do
    GenServer.call __MODULE__, {:stack, query}
  end

  #####
  # GenServer implementation

  def init(_args) do
    {:ok, %State{stack: []}}
  end

  def handle_cast({:dispatch, event}, state) do
    {:noreply, %{state | stack: state.stack ++ [event]}}
  end

  def handle_call(:stack, _from, state) do
    {:reply, state.stack, state}
  end

  def handle_call({:stack, query}, state) do
    result = Map.filter(state.stack, query)
    {:reply, state.}
  end
end
