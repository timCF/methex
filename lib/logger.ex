defmodule Methex.Logger do
	@methex_prefix "logger_"
	@methex_keys Enum.map(["debug","info","warn","error"], &(@methex_prefix<>&1))
	use GenEvent
	def init({__MODULE__, _}), do: {:ok, nil}
	def handle_call({:configure, _}, _), do: {:ok, :ok, nil}
	def handle_event({__, gl, _}, _) when node(gl) != node(), do: {:ok, nil}
	def handle_event({level, _, _}, _) do
		Methex.put(1,(@methex_prefix<>Atom.to_string(level)))
		{:ok, nil}
	end

	def get_freq, do: Enum.reduce(@methex_keys, %{}, &(Map.put(&2, &1, Methex.get_freq(&1))))

end
