defmodule BatchEcommerce.Accounts.Address do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.PostalCodeValidator

  @derive {Jason.Encoder, only: [:cep, :uf, :city, :district, :address, :home_number]}

  @required [:cep, :uf, :city, :district, :address, :complement, :home_number]
  @ufs ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA",
        "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN",
        "RS", "RO", "RR", "SC", "SP", "SE", "TO"]

  schema "addresses" do
    field :address, :string
    field :cep, :string
    field :uf, :string
    field :city, :string
    field :district, :string
    field :complement, :string
    field :home_number, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, @required)
    |> validate_required(@required, message: "O campo não pode estar em branco")
    |> validate_postal_code(:cep, country: "br", message: "CEP inválido")
    |> validate_uf()
    |> validate_length(:city, min: 3, max: 60, message: "Cidade inválida")
    |> validate_length(:district, min: 3, max: 50, message: "Bairro inválido")
    |> validate_length(:address, min: 5, max: 100, message: "Endereço inválido")
    |> validate_format(:home_number, ~r/^[0-9]+[a-zA-Z]*$/,
         message: "Numero inválido")
    |> unique_constraint_for_address()
  end

  defp validate_uf(changeset) do
    changeset
    |> validate_inclusion(:uf, @ufs, message: "não é uma UF válida")
    |> update_change(:uf, &String.upcase/1)
  end


  defp unique_constraint_for_address(changeset) do
    changeset
    |> unique_constraint([:cep, :home_number, :complement],
         name: :addresses_cep_home_number_complement_index,
         message: "Endereço já cadastrado"
       )
  end
end
