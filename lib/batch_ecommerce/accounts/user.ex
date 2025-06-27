defmodule BatchEcommerce.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoCommons.{EmailValidator, PhoneNumberValidator, DateValidator}
  alias BatchEcommerce.Accounts

  @derive {Jason.Encoder,
           only: [:id, :cpf, :name, :email, :phone_number, :birth_date, :addresses]}

  @required_fields_insert [:cpf, :name, :email, :phone_number, :birth_date, :password]
  @required_fields_update [:name, :email, :phone_number, :birth_date]
  @unique_fields [:email, :cpf, :phone_number]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :cpf, :string
    field :name, :string
    field :email, :string
    field :phone_number, :string
    field :birth_date, :date
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :password, :string, virtual: true

    many_to_many :addresses, BatchEcommerce.Accounts.Address,
      join_through: "users_addresses",
      on_replace: :delete

    has_many :cart_products, BatchEcommerce.ShoppingCart.CartProduct, on_delete: :delete_all

    has_one :company, BatchEcommerce.Accounts.Company, on_replace: :update, on_delete: :delete_all

    has_many :order, BatchEcommerce.Order.Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def form_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash | @required_fields_insert])
    |> validate_required(@required_fields_insert)
    |> validate_cpf()
    |> validate_name()
    |> validate_email(:email)
    |> validate_phone_number(:phone_number, country: "br")
    |> validate_date(:birth_date,
      before: validate_date_before(),
      after: validate_date_after(),
      message: "Data inválida"
    )
    |> validate_confirmation(:password, message: "As senhas não coincidem")
    |> cast_assoc(:addresses)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
    |> unique_constraint(:phone_number)
  end

  @doc false
  def insert_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash | @required_fields_insert])
    |> validate_required(@required_fields_insert)
    |> validate_cpf()
    |> validate_name()
    |> validate_email(:email)
    |> validate_phone_number(:phone_number, country: "br")
    |> validate_date(:birth_date,
      before: validate_date_before(),
      after: validate_date_after(),
      message: "Data inválida"
    )
    |> validate_confirmation(:password, message: "As senhas não coincidem")
    |> cast_assoc(:addresses)
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
    |> cast_assoc(:addresses)
    |> unique_constraint(:email)
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
    do: changeset |> validate_length(:cpf, is: 11)

  defp validate_name(changeset),
    do: changeset |> validate_length(:name, min: 2, max: 60)

  defp validate_date_before(), do: Date.utc_today() |> Date.shift(year: -18)

  defp validate_date_after(), do: Date.new!(1900, 1, 1)

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%BatchEcommerce.Accounts.User{password_hash: password_hash}, password)
      when is_binary(password_hash) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, password_hash)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end
end
