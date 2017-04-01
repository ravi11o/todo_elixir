defmodule Todo.Database do
  
  use GenServer

  def start_link(db_folder) do

    IO.puts "Starting database server"

    GenServer.start_link(__MODULE__, db_folder, name: :database_server)

  end


  def store(key, data) do

    key
    |> choose_worker
    |> Todo.DatabaseWorker.store(key, data)

  end

  def get(key) do

    key
    |> choose_worker
    |> Todo.DatabaseWorker.get(key)

  end

  defp choose_worker(key) do

    GenServer.call(:database_server, {:choose_worker, key})

  end


  def init(db_folder) do

    {:ok, start_workers(db_folder)}

  end

  defp start_workers(db_folder) do
    for index <- 1..3, into: Map.new do
      {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
      {index - 1, pid}
    end
  end

  def handle_call({:choose_worker, key}, _, workers) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(workers, worker_key), workers}
  end
end