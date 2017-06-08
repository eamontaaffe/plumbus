defmodule EventSource.Store do
  use GenServer

  @vsn "0"
  defmodule State do
    defstruct stack: []
  end

  # defmodule Index do
  #   defstruct name: "", filter: fn() -> false end, stack: []
  # end

  #####
  # Exteral API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def dispatch(event) do
    GenServer.cast __MODULE__, {:dispatch, event}
  end

  def stack() do
    GenServer.call __MODULE__, :stack
  end

  # def register_index(name, filter) do
  #   GenServer.cast __MODULE__, {:register_index, name, filter}
  # end

  # def initialise_index(name) do
  #   GenServer.cast __MODULE__, {:initialise_index, name}
  # end

  def stack(query) do
    GenServer.call __MODULE__, {:stack, query}
  end

  #####
  # GenServer implementation

  def init(_args) do
    {:ok, %State{stack: [], indexs: []}}
  end

  def handle_cast({:dispatch, event}, state) do
    {:noreply, %{state | stack: state.stack ++ [event]}}
  end

  def handle_call(:stack, _from, state) do
    {:reply, state.stack, state}
  end

  # def handle_cast({:register_index, name, filter}, state) do
  #   {
  #     :noreply,
  #     %{state | indexs: state.indexs ++ [
  #       %Index{
  #         name: name,
  #         filter: filter,
  #         stack: [],
  #       }
  #     ]}
  #   }
  # end

  # def handle_cast({:initialise_index, name}, state) do
  #   index = Enum.find_value(state.indexs, fn(index) -> index.name == name end)
  #   stack = Enum.filter(state.stack, fn(fact) -> index.filter.(fact) end)
  #   {:noreply, %state}
  # end

  def handle_call({:stack, query}, state) do
    result = Map.filter(state.stack, query)
    {:reply, state.}
  end
end
