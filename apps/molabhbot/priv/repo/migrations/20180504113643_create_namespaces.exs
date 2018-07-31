defmodule Molabhbot.Repo.Migrations.CreateNamespaces do
  use Ecto.Migration

  def change do
    create table(:namespaces) do
      add :ns, :string

      timestamps()
    end

    create unique_index(:namespaces, [:ns])
  end
end
