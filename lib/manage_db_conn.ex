defmodule StreamingChunked.ManageDbConn do

  @hostname "localhost"
  @username "postgres"
  @password "postgres"

  def create_conn(database) do
    Postgrex.start_link(hostname: @hostname, username: @username, password: @password, database: database)
  end

  def destroy_conn(pid) do
    Process.exit(pid, :normal)
  end
end
