defmodule Iphod.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :realname, :string
      add :encrypted_password, :string
      add :email, :string
      add :description, :text

      timestamps()
    end

  end
end
