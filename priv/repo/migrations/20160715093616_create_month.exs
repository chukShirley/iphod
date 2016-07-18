defmodule Iphod.Repo.Migrations.CreateMonth do
  use Ecto.Migration

  def change do
    create table(:months) do
        add :name, :string
        add :year, :string
        add :code, :string
      timestamps
    end

  end
end
