defmodule BatchEcommerce.Accounts.UsersAddresses do
  use Ecto.Schema

  @primary_key false
  schema "users_addresses" do
    belongs_to :user, BatchEcommerce.Accounts.User
    belongs_to :address, BatchEcommerce.Accounts.Address

    timestamps()
  end
end
