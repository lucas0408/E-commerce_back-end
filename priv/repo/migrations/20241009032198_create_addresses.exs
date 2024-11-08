defmodule BatchEcommerce.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :cep, :string
      add :uf, :string
      add :city, :string
      add :district, :string
      add :address, :string
      add :complement, :string
      add :home_number, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: true
      add :company_id, references(:companies), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:addresses, [:user_id])
    create index(:addresses, [:company_id])

    create constraint(:addresses, :must_have_one_owner,
      check: "(user_id IS NOT NULL AND company_id IS NULL) OR (company_id IS NOT NULL AND user_id IS NULL)"
    )
  end
end
