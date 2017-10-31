defmodule Iphod.Chat do
  use IphodWeb, :model

  schema "chat" do
    field :section, :string, default: "lobby"
    field :text,    :string, default: ""
    field :user,    :string, default: "anon"
    field :comment, :string, default: ""
    
    timestamps()
  end

  @required_fields ~w(section, text, user, comment)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
  
end

