defmodule BatchEcommerce.Repo.Migrations.CompaniesAddresses do
  use Ecto.Migration

  def change do
    create table(:companies_addresses, primary_key: false) do
      add :company_id, references(:companies, on_delete: :delete_all)
      add :address_id, references(:addresses, on_delete: :delete_all)
    end

    create index(:companies_addresses, [:company_id])
    create unique_index(:companies_addresses, [:company_id, :address_id])
  end
end
