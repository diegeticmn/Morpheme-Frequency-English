defmodule Nominals do

  def findnoms(file) do
    File.stream!(file)
    |> Stream.map(&String.split(&1))
    |> Enum.to_list
    |> List.flatten
    |> Enum.map(fn(x) -> if(Regex.match?(~r/ment$|ness$|tion$|sion$|ance$|ence$|ism$|ure$|age$|al$/, x), do: x) end)
    |> List.flatten
    |> Enum.reject(fn(x) -> x == nil end)
  end

  def nomcount(file) do
    file
    |> findnoms
    |> count
    |> tocsv
  end

  def morphemecount(file) do
    file
    |> findnoms
    |> morpheme
    |> count
    |> tocsv
  end

   defp morpheme(list) do
     new_list = Enum.map(list, &String.split_at(&1, -4))
     morpheme_list = for {_a, b} <- new_list, do: [] ++ b
     three_list = Enum.map(morpheme_list, fn(x) -> if(Regex.match?(~r/ism$|ure$|age$/, x), do: String.slice(x, -3..-1), else: x) end)
     Enum.map(three_list, fn(x) -> if(Regex.match?(~r/al$/, x), do: String.slice(x, -2..-1), else: x) end)
   end

   defp count(words) when is_list(words) do
     Enum.reduce(words, %{}, &update_count/2)
   end

   defp update_count(word, acc) do
     Map.update(acc, word, 1, &(&1 + 1))
   end

   defp tocsv(map) do
     File.open("morphemefreq.csv", [:write, :utf8], fn(file) ->
       Enum.each(map, &IO.write(file, Enum.join(Tuple.to_list(&1), ", ")<>"\n"))
     end)
   end

end

IO.inspect Nominals.morphemecount("YOURFILE.txt")
