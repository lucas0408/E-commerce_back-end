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
    |> validate_required(@required)
    |> validate_postal_code(:cep, country: "br")
    |> validate_uf()
    |> validate_length(:cep, is: 9)
    |> validate_format(:cep, ~r/^\d{5}-\d{3}$/, message: "deve estar no formato 00000-000")
    |> validate_inclusion(:uf, @ufs, message: "não é uma UF válida")
    |> validate_length(:city, min: 2, max: 50)
    |> validate_length(:district, min: 2, max: 50)
    |> validate_length(:address, min: 5, max: 100)
    |> validate_format(:home_number, ~r/^[0-9]+[a-zA-Z]*$/, 
         message: "deve conter números e pode ter letras no final")
    |> validate_no_special_chars(:city)
    |> validate_no_special_chars(:district)
    |> validate_no_special_chars(:address)
    |> validate_no_special_chars(:complement)
    |> unique_constraint_for_address()
  end

  defp validate_uf(changeset) do
    changeset
    |> validate_length(:uf, is: 2)
    |> update_change(:uf, &String.upcase/1)
  end

  defp validate_no_special_chars(changeset, field) do
    validate_format(changeset, field, ~r/^[a-zA-Z0-9\sáàâãéèêíïóôõöúçñÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇÑ\-]+$/,
      message: "não pode conter caracteres especiais"
    )
  end

  defp unique_constraint_for_address(changeset) do
    changeset
    |> unique_constraint([:cep, :home_number, :complement],
         name: :addresses_cep_home_number_complement_index,
         message: "endereço já cadastrado"
       )
  end
end