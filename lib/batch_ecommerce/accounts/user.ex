defmodule BatchEcommerce.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :cpf, :string
    field :email, :string
    field :phone, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :address, BatchEcommerce.Accounts.Address

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:cpf, :name, :address_id, :email, :phone, :password, :password_hash])
    |> validate_required([:cpf, :name, :address_id, :email, :phone, :password])
    |> unique_constraint([:email, :cpf, :phone])
    |> password_hash()
  end

  defp password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp password_hash(changeset), do: changeset

  defp validate_email(user),
  do: user |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Enter a valid email")

  defp validate_unique_email(user) do
    user
    |> unsafe_validate_unique(:email, HomerSalgateria.Repo, message: "This Email is already in use")
    |> unique_constraint(:email, name: :users_email_index)
  end

  defp validate_cpf(user),
    do: user |> validate_length(:cpf, is: 11, message: "Enter a valid CPF")

  defp validate_unique_cpf(user) do
    user
    |> unsafe_validate_unique(:cpf, HomerSalgateria.Repo, message: "This CPF is already in use")
    |> unique_constraint(:cpf, name: :users_cpf_index)
  end

  defp validate_numero_phone(user),
  do:
    validate_length(user, :numero_telefone,
      is: 11,
      message: "Enter a valid phone number"
    )

  defp validate_unique_phone(user) do
    user
      |> unsafe_validate_unique(:phone, BatchEcommerce.Repo, message: "This phone is already in use")
      |> unique_constraint(:cpf, name: :users_cpf_index)
  end

  defp validate_nome(user),
    do: validate_length(user, :nome, min: 2, max: 60, message: "Enter a valid phone name")

  defp validate_senha(user) do
    user
    |> validate_length(:senha,
      min: 8,
      max: 60,
      message: "Insira uma senha com no mínimo 8 caracteres"
      )
      |> validate_confirmation(:senha, message: "As senhas não são iguais")
      |> put_password_hash()
    end
end
