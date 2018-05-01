defmodule Molabhbot.Repo.Migrations.SeparateNamespaceTable do
  use Ecto.Migration

  def change do
    drop table(:tags)

    create table(:tags) do
      add :ns_id, references(:namespaces)
      add :name, :string

      timestamps()
    end

    create unique_index(:tags, [:name])
  end
end
