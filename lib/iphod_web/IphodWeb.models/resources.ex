defmodule Iphod.Resources do
  use IphodWeb, :model

  schema "resources" do
    field :name, :string
    field :url, :string
    field :description, :string
    field :of_type, :string
    field :keys, {:array, :string}
    field :key_string, :string, virtual: true

    timestamps()
  end

  @required_fields ~w(name of_type)
  @optional_fields ~w(description url keys)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> cast(params, ~w(key_string), [])
    |> put_key_list
  end

  def put_key_list(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{key_string: keys}} ->
        put_change( changeset, 
                    :keys, 
                    keys |> String.split(",") |> Enum.map( &( String.trim(&1) ) )
                  )
      _ ->
        changeset
    end
  end

end
