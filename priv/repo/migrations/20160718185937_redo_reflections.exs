defmodule Iphod.Repo.Migrations.RedoReflections do
  use Ecto.Migration

  def change do
    alter table(:reflections) do
      add :date, :string
      add :markdown, :text
      remove :year
      remove :text
      remove :name
    end
  end
end
