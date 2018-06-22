# StreamingChunked

Database requirements for running the app:

- Postgresql 9.5 or newer
- Create two databases `foo` and `bar`
- create a table `source` with three integer columns (a,b,c) in `foo`
- and a table `dest` with three integer columns (a,b,c) in `bar`

PS: It is necessary to change the database credentials in file lib/manage_db_conn.ex in order to work, it is currently hardcoded there.

Simple web application to accomplish the following on a pre-created database with the necessary table structures:

- opens a connection to the database `foo`
- fills the table `source` with 1 million rows where:
--column a contains the numbers from 1 to 1e6
--column b has a % 3
--column c has a % 5
- opens a connection to the database `bar`
- copies the data from table `source` in `foo` to table `dest` in `bar` using postgresql copy command
(without saving data into a file)
Then:
- starts a web server that has two endpoints: `./dbs/foo/tables/source` and `./dbs/bar/tables/dest`
--upon a `GET` request to either of the two it must respond with contents of a corresponding table serialized as CSV and using HTTP chunked encoding. Data must be streamed from the database upon a request, not stored in a file or cached in memory

All the transactions used Streams to give a better performance and support greater amounts of data.


# How to run
The app can be run by Elixir's cli IEX, here's an example:

```streaming_chunked git:(master) ✗ iex -S mix
Erlang/OTP 20 [erts-9.2.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.6.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> StreamingChunked.Pipeline.run_pipeline()
inserting into source
copying source into dest
initializing server
{:ok, #PID<0.203.0>}