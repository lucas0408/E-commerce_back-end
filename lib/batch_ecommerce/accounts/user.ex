defmodule BatchEcommerce.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.{EmailValidator, PhoneNumberValidator, DateValidator}
  alias BatchEcommerce.Accounts

  @required_fields_insert [:cpf, :name, :email, :phone_number, :birth_date, :password]
  @required_fields_update [:cpf, :name, :email, :phone_number, :birth_date]
  @unique_fields [:email, :cpf, :phone_number]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :cpf, :string
    field :name, :string
    field :email, :string
    field :phone_number, :string
    field :birth_date, :date
    field :password_hash, :string
    field :password, :string, virtual: true

    has_one :address, BatchEcommerce.Accounts.Address, on_replace: :update, on_delete: :delete_all

    has_one :cart, BatchEcommerce.ShoppingCart.Cart, on_replace: :update, on_delete: :delete_all

    has_one :company, BatchEcommerce.Accounts.Company, on_replace: :update, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def insert_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash | @required_fields_insert])
    |> validate_required(@required_fields_insert)
    |> validate_cpf()
    |> validate_name()
    |> validate_email(:email, message: "E-mail inválido")
    |> validate_phone_number(:phone_number, country: "br", message: "Número de telefone inválido")
    |> validate_date(:birth_date,
      before: validate_date_before(),
      after: validate_date_after(),
      message: "Data inválida"
    )
    |> validate_confirmation(:password, message: "As senhas não correspondem")
    |> cast_assoc(:address)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
    |> unique_constraint(:phone_number)
    |> validate_uniqueness_of_fields(@unique_fields)
    |> password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields_update)
    |> validate_required(@required_fields_update)
    |> validate_cpf()
    |> validate_name()
    |> validate_email(:email, message: "Invalid email")
    |> validate_phone_number(:phone_number, country: "br", message: "Invalid phone number")
    |> validate_date(:birth_date,
      before: validate_date_before(),
      after: validate_date_after(),
      message: "Data inválida"
    )
    |> cast_assoc(:address)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
    |> unique_constraint(:phone_number)
  end

  defp password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp password_hash(changeset), do: changeset

  defp validate_uniqueness_of_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      changes = get_change(acc_changeset, field)

      if changes && Accounts.user_exists_with_field?(field, changes) do
        add_error(acc_changeset, field, "Already in use")
      else
        acc_changeset
      end
    end)
  end

  defp validate_cpf(changeset),
    do: changeset |> validate_length(:cpf, is: 11, message: "Enter a valid CPF")

  defp validate_name(changeset),
    do: changeset |> validate_length(:name, min: 2, max: 60, message: "Enter a valid name")

  defp validate_date_before(), do: Date.utc_today() |> Date.shift(year: -18)

  defp validate_date_after(), do: Date.new!(1900, 1, 1)
end
