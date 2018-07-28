defmodule StreamingChunked.Pipeline do

  alias StreamingChunked.PrepareDataBase
  alias StreamingChunked.ManageDbConn
  alias StreamingChunked.Server

  def run_pipeline() do
    {:ok, foo_pid} = ManageDbConn.create_conn("foo")

    IO.puts "inserting into source"

    PrepareDataBase.insert_random_1e6_times(foo_pid)

    {:ok, bar_pid} = ManageDbConn.create_conn("bar")

    IO.puts "copying source into dest"

    PrepareDataBase.copy_source_to_dest(foo_pid, bar_pid)

    ManageDbConn.destroy_conn(foo_pid)
    ManageDbConn.destroy_conn(bar_pid)

    IO.puts "initializing server"

    start_server()
  end

  def start_server() do
    Supervisor.init([{Server, []}], strategy: :one_for_one)
  end
end
