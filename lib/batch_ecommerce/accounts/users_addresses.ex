defmodule BatchEcommerce.Accounts.UsersAddresses do
  use Ecto.Schema

  @primary_key false
  schema "users_addresses" do
    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id
    belongs_to :address, BatchEcommerce.Accounts.Address

    timestamps()
  end
end
