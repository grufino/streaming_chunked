defmodule StreamingChunked.PrepareDataBase do

  @insert_qty 1000000

  @timeout 600_000

  @chunk_size 1000

  @maximum_number 1000000

  def generation_times(times) do
    for _ <- 1..times, do: generate_number_tuple()
  end

  def generate_number_tuple() do
      random_number = :rand.uniform(@maximum_number)

      {random_number, rem(random_number, 3), rem(random_number, 5)}
  end

  def insert_random_1e6_times(foo_pid) do
    numbers_tuple = generation_times(@insert_qty)

    Stream.chunk_every(numbers_tuple, @chunk_size)
    |> Enum.map(fn chunk -> insert_list(chunk, foo_pid, "source") end)
  end

  def copy_source_to_dest(foo_pid, bar_pid) do
    Postgrex.transaction(foo_pid, fn(conn) ->
      query = Postgrex.prepare!(conn, "", "COPY source TO STDOUT",[])
      stream = Postgrex.stream(conn, query, [], max_rows: @chunk_size)

      Enum.map(stream, fn chunk -> stream_to_table(chunk, bar_pid, "dest") end)
    end, timeout: @timeout)
  end

  def insert_tuple(values_string, db_pid, table) do
    query =
    "INSERT INTO #{table} (a, b, c) VALUES #{String.slice(values_string, 1..-1)}"
    Postgrex.query!(db_pid, query, [])
  end

  def insert_list(number_tuple_list, db_pid, table) do
    number_tuple_list
    |> List.foldl("",  &build_insert_string/2)
    |> insert_tuple(db_pid, table)
  end

  def build_insert_string({random_num, rem_3, rem_5}, result_string) do
    result_string <> ",(#{random_num}, #{rem_3}, #{rem_5})"
  end

  def stream_to_table(%Postgrex.Result{rows: rows, num_rows: num_rows}, bar_pid, table) when num_rows > 0 do
    Enum.map(rows,
      fn row -> String.trim(row, "\n")
                |> String.split("\t")
                |> List.to_tuple() end
    )
    |> insert_list(bar_pid, table)
  end

  def stream_to_table(_,_,_), do: nil
end
