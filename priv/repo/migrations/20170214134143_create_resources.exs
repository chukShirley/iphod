defmodule Iphod.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :name, :string
      add :url, :string
      add :description, :string
      add :of_type, :string
      add :keys, {:array, :text}

      timestamps()
    end
  end
end
