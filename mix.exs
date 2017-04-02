defmodule UeberauthPaypal.Mixfile do
  use Mix.Project
  @version "0.2.0"
  @url "https://github.com/smeevil/ueberauth_paypal"
  def project do
    [
      app: :ueberauth_paypal,
      version: @version,
      elixir: "~> 1.3",
      name: "Ueberauth Paypal Strategy",
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      source_url: @url,
      homepage_url: @url,
      description: "An Uberauth strategy for Paypal authentication.",
      deps: deps()
     ]
  end

  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  defp deps do
    [
      {:oauth2, "~> 0.9.1"},
      {:ueberauth, "~> 0.4.0"}
    ]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Gerard de Brieder"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}]
  end
end
