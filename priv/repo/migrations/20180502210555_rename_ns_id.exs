defmodule Molabhbot.Repo.Migrations.RenameNsId do
  use Ecto.Migration

  def change do
    drop table(:tags)

    create table(:tags) do
      add :namespace_id, references(:namespaces)
      add :name, :string

      timestamps()
    end

    create unique_index(:tags, [:name])
  end
end
