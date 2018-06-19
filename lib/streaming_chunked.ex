defmodule StreamingChunked do

  @1e6 1000000

  def insert_random_1e6_times() do

    {:ok, pid} = create_conn("foo")

    @1e6
    |> GenerateNumber.generation_times()
    |> Enum.map(fn number_tuple -> insert_tuple(pid, number_tuple) end)
  end

  def create_conn(database) do
    Postgrex.start_link(hostname: "localhost", username: "postgres", password: "", database: database)
  end

  def insert_tuple(db_pid, {random_num, rem_3, rem_5}) do
    Postgrex.query!(db_pid, "INSERT INTO source (a, b, c) VALUES (#{random_num}, #{rem_3}, #{rem_5})", [])
  end
end
