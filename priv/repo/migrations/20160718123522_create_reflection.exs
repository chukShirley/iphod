defmodule Iphod.Repo.Migrations.CreateReflection do
  use Ecto.Migration

  def change do
    create table(:reflections) do
        add :name, :string
        add :year, :string
        add :text, :string
        add :author, :string
        add :read_cnt, :integer, default: 0
      timestamps
    end

  end
end
