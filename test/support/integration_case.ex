defmodule Iphod.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Iphod.ConnCase
      use PhoenixIntegration
    end
  end
end