defmodule Molabhbot.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :ns, :string
      add :name, :string

      timestamps()
    end

    create unique_index(:tags, [:ns])
    create unique_index(:tags, [:name])
  end
end
