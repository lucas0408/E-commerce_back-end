defmodule BatchEcommerce.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  require IEx
  alias BatchEcommerce.Repo

  alias BatchEcommerce.Accounts.User

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
  def get_user(id), do: Repo.get(User, id) |> Repo.preload(:addresses)

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

  alias BatchEcommerce.Accounts.Company

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies do
    Repo.all(Company) |> companies_preload()
  end

  def companies_preload(companies) do
    companies
    |> Repo.preload(:addresses) |> Repo.preload(products: [:categories])
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company(id), do: Repo.get(Company, id) |> companies_preload()

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, company} ->
        {:ok, companies_preload(company)}

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
        {:ok, companies_preload(company_updated)}

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
  Returns the list of addresses.
  ## Examples
      iex> list_addresses()
      [%Address{}, ...]
  """
  def list_addresses do
    Repo.all(Address)
  end

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
  Creates a address.
  ## Examples
      iex> create_address(%{field: value})
      {:ok, %Address{}}
      iex> create_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.
  ## Examples
      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}
      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

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
