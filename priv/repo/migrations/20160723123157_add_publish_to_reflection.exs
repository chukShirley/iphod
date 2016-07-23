defmodule Iphod.Repo.Migrations.AddPublishToReflection do
  use Ecto.Migration

  def change do
    alter table(:reflections) do
      add :published, :boolean, default: false
    end
  end
end
