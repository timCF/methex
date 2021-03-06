defmodule Methex.Mixfile do
  use Mix.Project

  def project do
    [
     app: :methex,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     description: "Metrics system (folsom wrapper) + logger backend",
     source_url: "https://github.com/timCF/methex",
     package: [
       licenses: ["Apache 2.0"],
       maintainers: ["Ilja Tkachuk aka timCF"],
       links: %{
         "GitHub" => "https://github.com/timCF/methex",
         "Author's home page" => "https://timcf.github.io/"
       }
     ],
     # Docs
     name: "Methex",
     docs: [main: "readme", extras: ["README.md"]],

    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications:  [
                      :logger,
                      :folsom
                    ],
     mod: {Methex, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:folsom, "~> 0.8.5"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end
end
