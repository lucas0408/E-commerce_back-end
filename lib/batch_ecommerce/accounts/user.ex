defmodule BatchEcommerce.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  require IEx
  alias BatchEcommerce.Accounts

  @unique_fields [:email, :cpf, :phone]

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :cpf, :string
    field :name, :string
    belongs_to :address, BatchEcommerce.Accounts.Address
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:cpf, :name, :email, :phone, :password, :password_hash])
    |> validate_required([:cpf, :name, :email, :phone, :password])
    |> cast_assoc(:address)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
    |> unique_constraint(:phone)
    |> validate_uniqueness_of_fields(@unique_fields)
    |> password_hash()
  end

  defp password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp password_hash(changeset), do: changeset

  defp validate_uniqueness_of_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      changes = get_change(acc_changeset, field)

      if changes && Accounts.user_exists_with_field?(field, changes) do
        add_error(acc_changeset, field, "already in use")
      else
        acc_changeset
      end
    end)
  end
end
