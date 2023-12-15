defmodule PairingHeap.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :pairing_heap,
      version: @version,
      elixir: "~> 1.15",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/epfahl/pairing_heap",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Elixir implementation of a pairing heap."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Eric Pfahl"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/epfahl/pairing_heap"
      }
    ]
  end

  defp docs() do
    [
      main: "PairingHeap",
      extras: ["README.md"]
    ]
  end
end
