defmodule BatchEcommerce.Accounts.Company do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.{EmailValidator, PhoneNumberValidator}
  alias BatchEcommerce.Accounts

  schema "companies" do
    field :name, :string
    field :cnpj, :string
    field :email, :string
    field :phone_number, :string

    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id

    has_one :address, BatchEcommerce.Accounts.Address, on_replace: :update, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:cnpj, :name, :email, :phone_number, :user_id])
    |> validate_required([:cnpj, :name, :email, :phone_number])
    |> validate_name()
    |> validate_cnpj()
    |> validate_email(:email, message: "invalid email")
    |> validate_phone_number(:phone_number, country: "br", message: "Invalid phone number")
    |> validate_uniqueness_of_fields([:cnpj, :phone_number, :name])
    |> assoc_constraint(:user)
    |> cast_assoc(:address)
  end

  defp validate_uniqueness_of_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      changes = get_change(acc_changeset, field)

      if changes && Accounts.company_exists_with_field?(field, changes) do
        add_error(acc_changeset, field, "Already in use")
      else
        acc_changeset
      end
    end)
  end

  defp validate_cnpj(changeset),
    do: changeset |> validate_length(:cnpj, is: 18, message: "Enter a valid CNPJ")

  defp validate_name(changeset),
    do: changeset |> validate_length(:name, min: 2, max: 60, message: "Enter a valid name")
end
