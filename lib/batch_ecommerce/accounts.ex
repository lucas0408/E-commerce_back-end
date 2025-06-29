defmodule BatchEcommerce.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require IEx
  alias BatchEcommerce.Repo

  alias BatchEcommerce.Accounts.User
  alias BatchEcommerce.Catalog.Minio

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users, do: Repo.all(User) |> Repo.preload([:addresses])

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(nil), do: nil
  def get_user(id), do: Repo.get(User, id) |> Repo.preload([:addresses])


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
    |> case do
      {:ok, user} ->
        {:ok, Repo.preload(user, :addresses)}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    |> case do
      {:ok, user_updated} ->
        {:ok, Repo.preload(user_updated, :addresses)}

      {:error, changeset} ->
        {:error, changeset}
    end
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

  def form_change_user(%User{} = user, attrs \\ %{}) do
    User.form_changeset(user, attrs)
  end

  def insert_change_user(%User{} = user, attrs \\ %{}) do
    User.insert_changeset(user, attrs)
  end

  def update_change_user(%User{} = user, attrs \\ %{}) do
    User.update_changeset(user, attrs)
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
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

  def user_preload_company(user) do
    Repo.preload(user, :company)
  end

  alias BatchEcommerce.Accounts.Company

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """

  def companies_preload_address(companies) do
    companies
    |> Repo.preload(:addresses)
  end

  def get_company_by_user_id(user_id), do: Repo.get_by(Company, user_id: user_id)


  def get_company!(id), do: Repo.get(Company, id) |> companies_preload_address()

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    changeset =
      %Company{}
      |> Company.changeset(attrs)

    with {:ok, company} <- Repo.insert(changeset),
        {:ok, _msg} <- Minio.create_public_bucket(company.name) do
        {:ok, companies_preload_address(company)}
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def company_exists_with_field?(field, value) do
    query = from u in Company, where: field(u, ^field) == ^value
    Repo.exists?(query)
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, company_updated} ->
        {:ok, companies_preload_address(company_updated)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  alias BatchEcommerce.Accounts.Address

  @doc """
  Gets a single address.
  Raises `Ecto.NoResultsError` if the Address does not exist.
  ## Examples
      iex> get_address!(123)
      %Address{}
      iex> get_address!(456)
      ** (Ecto.NoResultsError)
  """
  def get_address(id), do: Repo.get(Address, id)



  @doc """
  Deletes a address.
  ## Examples
      iex> delete_address(address)
      {:ok, %Address{}}
      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}
  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.
  ## Examples
      iex> change_address(address)
      %Ecto.Changeset{data: %Address{}}
  """
  def change_address(%Address{} = address, attrs \\ %{}) do
    Address.changeset(address, attrs)
  end
end
