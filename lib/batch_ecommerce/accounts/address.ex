defmodule BatchEcommerce.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.PostalCodeValidator

  @required [:cep, :uf, :city, :district, :address, :complement, :home_number]

  schema "addresses" do
    field :address, :string
    field :cep, :string
    field :uf, :string
    field :city, :string
    field :district, :string
    field :complement, :string
    field :home_number, :string
    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id
    belongs_to :company, BatchEcommerce.Accounts.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_postal_code(:cep, country: "br")
    |> validate_uf()
  end

  defp validate_uf(changeset), do: changeset |> validate_length(:uf, is: 2)
end
