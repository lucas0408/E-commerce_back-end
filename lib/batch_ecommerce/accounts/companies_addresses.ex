defmodule BatchEcommerce.Accounts.CompaniesAddresses do
  use Ecto.Schema

  @primary_key false
  schema "companies_addresses" do
    belongs_to :company, BatchEcommerce.Accounts.Company
    belongs_to :address, BatchEcommerce.Accounts.Address

    timestamps()
  end
end
