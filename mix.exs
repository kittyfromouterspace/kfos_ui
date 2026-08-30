defmodule KfosUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :kfos_ui,
      version: "0.1.0",
      elixir: "~> 1.15",
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
      {:jason, "~> 1.2"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.1"}
    ]
  end
end
