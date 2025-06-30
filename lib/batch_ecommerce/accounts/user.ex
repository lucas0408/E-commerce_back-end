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
    field :profile_filename, :string

    many_to_many :addresses, BatchEcommerce.Accounts.Address,
      join_through: "users_addresses",
      on_replace: :delete

    has_many :cart_products, BatchEcommerce.ShoppingCart.CartProduct, on_delete: :delete_all

    has_one :company, BatchEcommerce.Accounts.Company, on_replace: :update, on_delete: :delete_all

    has_many :order, BatchEcommerce.Order.Order

    timestamps(type: :utc_datetime)
  end

  def form_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash | @required_fields_insert])
    |> validate_form_fields(@required_fields_insert)
  end

  def insert_changeset(user, attrs) do
    user
    |> cast(attrs, [:password_hash | @required_fields_insert])
    |> validate_form_fields(@required_fields_insert)
    |> validate_uniqueness_of_fields(@unique_fields)
    |> password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields_update)
    |> validate_form_fields(@required_fields_update)
    |> validate_uniqueness_of_fields(@unique_fields)
  end

  defp validate_form_fields(user, required_fields) do
    user
    |> validate_required(required_fields, message: "O campo não pode estar em branco")
    |> validate_cpf()
    |> validate_name()
    |> validate_email(:email, message: "Endereço de e-mail inválido")
    |> validate_phone_number(:phone_number, country: "br", message: "Número de telefone inválido")
    |> validate_date(:birth_date,
      before: validate_date_before(),
      after: validate_date_after(),
      message: "Data inválida"
    )
    |> validate_password()
    |> validate_confirmation(:password, message: "As senhas não coincidem")
    |> cast_assoc(:addresses)
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
        add_error(acc_changeset, field, "Já está em uso")
      else
        acc_changeset
      end
    end)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_errors(:password, &validate_length(&1, :password, min: 6, message: "A senha deve conter no mínimo 6 caracteres"))
    |> validate_errors(:password, &validate_format(&1, :password, ~r/[A-Za-z]/, message: "A senha deve conter ao menos uma letra"))
    |> validate_errors(:password, &validate_format(&1, :password, ~r/\d/, message: "A senha deve conter ao menos um número"))
    |> validate_errors(:password, &validate_format(&1, :password, ~r/[!@#$%^&*()_+\[\]{}:;"'\\|<>,.?\/~=-]/, message: "A senha deve conter ao menos um caractere especial"))
  end

  defp validate_errors(changeset, field, validation_fn) do
    if Keyword.has_key?(changeset.errors, field) do
      changeset
    else
      validation_fn.(changeset)
    end
  end


  defp validate_cpf(changeset) do
    cpf = get_field(changeset, :cpf)

    if Brcpfcnpj.cpf_valid?(cpf) do
      changeset
    else
      add_error(changeset, :cpf, "CPF inválido")
    end
  end

  defp validate_name(changeset),
    do: changeset |> validate_length(:name, max: 60, message: "O nome excedeu o limite de caracteres permitidos")

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
