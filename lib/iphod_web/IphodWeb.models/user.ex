defmodule Iphod.User do
  use IphodWeb, :model

  schema "users" do
    field :username, :string
    field :realname, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :email, :string
    field :description, :string

    timestamps()
  end

  @required_fields ~w(username realname password password_confirmation email)
  @optional_fields ~w(description)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required([:username, :email])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> validate_length(:password_confirmation, min: 6)
    |> validate_confirmation(:password)
  end

  def init_user do
    %{  username:               "",
        realname:               "",
        password:               "",
        password_confirmation:  "",
        email:                  "",
        description:            ""
    }
  end

  def get(id), do: Iphod.Repo.get(User, id)

  # def validate_confirmation(changeset, field) do
  #   value = get_field(changeset, field)
  #   confirmation_value = get_field(changeset, :"#{field}_confirmation")
  #   if value != confirmation_value do 
  #     add_error(changeset, :"#{field}_confirmation", "does not match")
  #   else 
  #     changeset
  #   end
  # end
end
