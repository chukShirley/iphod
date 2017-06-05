defmodule Iphod.Repo.Migrations.CreateDailyOptions do
  use Ecto.Migration

  def change do
    create table(:daily_options) do
      add :date, :date
      add :collect, :text
      add :invitatory, :text

      timestamps()
    end

  end
end
