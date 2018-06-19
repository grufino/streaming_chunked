defmodule GenerateNumber do

  @maximum_number 1000000

  def generation_times(times) do
    for _ <- 1..times, do: generate_number_tuple()
  end

  def generate_number_tuple() do
      random_number = :rand.uniform(@maximum_number)

      {random_number, rem(random_number, 3), rem(random_number, 5)}
  end
end
