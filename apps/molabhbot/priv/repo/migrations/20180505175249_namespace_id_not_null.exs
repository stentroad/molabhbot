defmodule Molabhbot.Repo.Migrations.NamespaceIdNotNull do
  use Ecto.Migration

  def change do
    drop table(:tags)

    create table(:tags) do
      add :name, :string
      add :namespace_id, references(:namespaces, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
    create index(:tags, [:namespace_id])
  end
end
