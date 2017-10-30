defmodule Iphod.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use IphodWeb.ConnCase
      use PhoenixIntegration
    end
  end
end