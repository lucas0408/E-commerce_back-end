defmodule BatchEcommerce.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :name, :string
    field :cpf, :string
    field :address_id, :integer
    field :email, :string
    field :phone, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:cpf, :name, :address_id, :email, :phone, :password, :password_hash])
    |> validate_required([:cpf, :name, :address_id, :email, :phone, :password])
    |> unique_constraint(:email)
    |> password_hash()
  end

  defp password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp password_hash(changeset), do: changeset
end
