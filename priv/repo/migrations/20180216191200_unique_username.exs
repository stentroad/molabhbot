defmodule Molabhbot.Repo.Migrations.UniqueUsername do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:username])
    drop unique_index(:users, [:email])
  end
end
