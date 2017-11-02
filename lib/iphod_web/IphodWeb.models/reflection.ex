require IEx
defmodule Iphod.Reflection do
  use IphodWeb, :model

  schema "reflections" do
        field :date, :string
        field :markdown, :string
        field :author, :string
        field :read_cnt, :integer, default: 0
        field :published, :boolean, default: false

    timestamps()
  end

  @required_fields ~w(date author markdown published)
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
