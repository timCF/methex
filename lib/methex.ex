defmodule Methex do
	use Application
	@etstable :__methex__cache__
	@def_ttl 60

	# See http://elixir-lang.org/docs/stable/elixir/Application.html
	# for more information on OTP Applications
	def start(_type, _args) do
		import Supervisor.Spec, warn: false
		if (:ets.info(@etstable) != :undefined), do: raise("ets table #{inspect @etstable} already exist")
		true = (@etstable == :ets.new(@etstable, [:public, :named_table, :ordered_set, {:write_concurrency, true}, {:read_concurrency, true}, :protected]))
		case Logger.add_backend({Methex.Logger, nil}) do
			{:ok, pid} when is_pid(pid) -> :ok
			{:error, :already_present} -> :ok
			some -> raise("can not start Methex.Logger backend, got #{inspect some}")
		end

		children = [
			# Define workers and child supervisors to be supervised
			# worker(Methex.Worker, [arg1, arg2, arg3])
		]

		# See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: Methex.Supervisor]
		Supervisor.start_link(children, opts)
	end

	@spec put(number, String.t, pos_integer) :: :ok
	def put(num, name, ttl \\ @def_ttl)
	def put(num, name, ttl) when is_number(num) and is_binary(name) and is_integer(ttl) and (ttl > 0) do
		case :ets.lookup(@etstable, name) do
			[{^name, ^ttl}] ->
				:ok = :folsom_metrics.notify(name, num)
			[] ->
				:ok = :folsom_metrics.new_histogram(name, :slide, ttl)
				true = :ets.insert(@etstable, {name, ttl})
				:ok = :folsom_metrics.notify(name, num)
			[{^name, _}] ->
				:ok = :folsom_metrics.delete_metric(name)
				:ok = :folsom_metrics.new_histogram(name, :slide, ttl)
				true = :ets.insert(@etstable, {name, ttl})
				:ok = :folsom_metrics.notify(name, num)
		end
	end

	@spec get(String.t) :: [number]
	def get(name) when is_binary(name) do
		case :folsom_metrics.get_metric_value(name) do
			[] -> []
			lst = [_|_] -> lst
		end
	end

	@spec get_average(String.t) :: float
	def get_average(name) when is_binary(name) do
		case get(name) do
			[] -> 0
			lst = [_|_] -> Enum.sum(lst) / length(lst)
		end
	end

	@spec get_freq(String.t) :: float
	def get_freq(name) when is_binary(name) do
		case :ets.lookup(@etstable, name) do
			[{^name, ttl}] -> ((get(name) |> length) / ttl)
			[] -> 0
		end
	end


	@spec keys :: [String.t]
	def keys, do: :ets.foldl(fn({k,_}, acc) -> [k|acc] end, [], @etstable)

end
