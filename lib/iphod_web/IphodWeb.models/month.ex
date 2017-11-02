defmodule Iphod.Month do
  use IphodWeb, :model

  schema "months" do
        field :name, :string
        field :year, :string
        field :code, :string
    timestamps()
  end

  @required_fields ~w(:name, :year, :code)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
