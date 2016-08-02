defmodule Iphod.Repo.Migrations.VssChangeStringToText do
  use Ecto.Migration

  def change do
    alter table(:bible) do
      modify :vss, {:array, :text}
    end
  end
end
