defmodule Methex do
  use Application
  use Silverb,[{"@def_ttl", 60}]
  use Tinca,  [
                :__methex__cache__
              ]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Tinca.declare_namespaces

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
    case Methex.Tinca.get(name, :__methex__cache__) do
      ^ttl -> 
        :ok = :folsom_metrics.notify(name, num)
      nil -> 
        :ok = :folsom_metrics.new_histogram(name, :slide, ttl)
        Methex.Tinca.put(ttl, name, :__methex__cache__)
        :ok = :folsom_metrics.notify(name, num)
      _ ->
        :ok = :folsom_metrics.delete_metric(name)
        :ok = :folsom_metrics.new_histogram(name, :slide, ttl)
        Methex.Tinca.put(ttl, name, :__methex__cache__)
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
  def get_freq(name) when is_binary(name), do: ((get(name) |> length) / Methex.Tinca.get(name, :__methex__cache__))

  @spec keys :: [String.t]
  def keys, do: Methex.Tinca.iterate_acc([], fn({k,_}, acc) -> [k|acc] end, :__methex__cache__)

end
