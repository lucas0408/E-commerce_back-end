defmodule BatchEcommerce.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :address, :string
    field :cep, :string
    field :uf, :string
    field :city, :string
    field :district, :string
    field :complement, :string
    field :home_number, :string
    has_one :user, BatchEcommerce.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:cep, :uf, :city, :district, :address, :complement, :home_number])
    |> validate_required([:cep, :uf, :city, :district, :address, :complement, :home_number])
  end
end
