defmodule Iphod.Repo.Migrations.CreateBible do
  use Ecto.Migration

  def change do
    create table(:bible) do
      add :trans, :string
      add :name, :string
      add :direction, :string, default: "LTR"
      add :book, :string
      add :chapter, :integer
      add :vss, {:array, :string}
    end

    create unique_index(:bible, [:trans, :book, :chapter])
  end
end
