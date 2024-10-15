defmodule BatchEcommerce.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users, do: Repo.all(User) |> Repo.preload([:address])

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id), do: Repo.get(User, id) |> Repo.preload(:address)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.insert_changeset(attrs)
    |> Repo.insert()
  end

  def user_exists_with_field?(field, value) do
    query = from u in User, where: field(u, ^field) == ^value
    Repo.exists?(query)
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def authenticate_user(email, plain_text_password) do
    query = from(u in User, where: u.email == ^email)

    case Repo.one(query) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(plain_text_password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
