defmodule BatchEcommerce.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :cpf, :string
      add :name, :string
      add :address_id, references(:addresses)
      add :email, :string
      add :phone, :string
      add :password_hash, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email, :cpf, :phone])
  end
end
