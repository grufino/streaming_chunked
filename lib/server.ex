defmodule StreamingChunked.Server do
  use Plug.Router

  alias StreamingChunked.ManageDbConn

  @timeout 6_000_000

  plug(:match)
  plug(:dispatch)

  def child_spec(_opts) do
    Plug.Adapters.Cowboy.http(__MODULE__, [])
  end

  get("/dbs/bar/tables/dest") do
    conn =
    conn
    |> send_chunked(200)

    {:ok, bar_pid} = ManageDbConn.create_conn("bar")

    send_table_stream_chunked(bar_pid, "dest", conn)
    conn
  end

  get("/dbs/foo/tables/source") do
    conn =
    conn
    |> send_chunked(200)

    {:ok, foo_pid} = ManageDbConn.create_conn("foo")

    send_table_stream_chunked(foo_pid, "source", conn)
    conn
  end

  match(_, do: send_resp(conn, 404, "Oops! Unexisting route"))

  def send_table_stream_chunked(db_pid, table, conn) do
    Postgrex.transaction(db_pid, fn(db_conn) ->
      query = Postgrex.prepare!(db_conn, "", "COPY #{table} TO STDOUT CSV",[])
      stream = Postgrex.stream(db_conn, query, [])

      Enum.map(stream, fn chunk -> put_chunk_stream(chunk, conn) end)
    end, timeout: @timeout)
  end

  def put_chunk_stream(%Postgrex.Result{rows: rows}, conn) do
    rows
    |> Enum.reduce_while(conn, fn (chunk, conn) ->
      case Plug.Conn.chunk(conn, chunk) do
        {:ok, conn} ->
          {:cont, conn}
        _ ->
          {:halt, conn}
      end
    end)
  end
end
