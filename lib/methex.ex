defmodule Methex do
  use Application
  use Silverb
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

  def notify(int, name) when is_number(int) and is_binary(name) do
    #
    # TODO
    #
  end

end
