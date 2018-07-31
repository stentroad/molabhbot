defmodule Molabhbot.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :namespace_id, references(:namespaces, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:tags, [:name])
    create index(:tags, [:namespace_id])
  end
end
