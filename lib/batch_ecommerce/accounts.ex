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
        IO.inspect(changeset)
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
    minio_bucket_name = normalize_bucket_name(attrs["name"])
    attrs = Map.put(attrs, "minio_bucket_name", minio_bucket_name)

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

  @min_length 3
  @max_length 63

  def normalize_bucket_name(name) do
    name
    |> String.downcase()
    |> remove_accents()
    |> String.replace(~r/[\s_]+/, "-")
    |> String.replace(~r/[^a-z0-9.-]/, "")
    |> String.trim_leading(".")
    |> String.trim_trailing(".")
    |> truncate_to_max()
    |> ensure_min_length()
  end

  defp remove_accents(string) do
    string
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/[\p{Mn}]/u, "")
  end

  defp truncate_to_max(string) when byte_size(string) > @max_length do
    String.slice(string, 0, @max_length)
  end

  defp truncate_to_max(string), do: string

  defp ensure_min_length(string) when byte_size(string) < @min_length do
    string <> "-bucket"
  end

  defp ensure_min_length(string), do: string

  def upload_image(socket, company_name, :user) do
    Minio.upload_images(socket, company_name, :image, :user)
  end

  def upload_image(socket, company_name, :company) do
    Minio.upload_images(socket, company_name, :image, :company)
  end

  def normalize_filename(name) do
    name
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(~r/[̀-ͯ]/, "")
    |> String.replace(~r/[^a-z0-9\._-]/, "_")
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

  alias BatchEcommerce.Accounts.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  # Função para listar notificações não lidas por user_id (UUID)
  def list_unread_notifications(user_id) when is_binary(user_id) do
    user_notifs =
      from(n in Notification,
        where: n.viewed == false and n.recipient_user_id == ^user_id,
        order_by: [desc: n.inserted_at],
        limit: 10
      )
      |> Repo.all()

    %{
      user_notifications: user_notifs || []
    }
  end

  def list_unread_notifications(company_id) when is_integer(company_id) do
    query = from n in Notification,
      where: n.viewed == false and n.recipient_company_id == ^company_id,
      order_by: [desc: n.inserted_at],
      limit: 10

    Repo.all(query)
  end



  def mark_as_viewed(notification_ids) when is_list(notification_ids) do
    from(n in Notification, where: n.id in ^notification_ids)
    |> Repo.update_all(set: [viewed: true])
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  def mark_all_as_read(user_id) when is_binary(user_id) do
    query =
      from n in Notification,
      where: n.viewed == false and
            (n.recipient_user_id == ^user_id)

    Repo.update_all(query, set: [viewed: true])
  end

  def mark_all_as_read(company_id) when is_integer(company_id) do
    query =
      from n in Notification,
      where: n.viewed == false and
            (n.recipient_company_id == ^company_id)

    Repo.update_all(query, set: [viewed: true])
  end

  def count_unread_notifications(user_id) when is_binary(user_id) do
    query =
      from n in Notification,
      where: n.viewed == false and
             (n.recipient_user_id == ^user_id)

    Repo.aggregate(query, :count)
  end

  def count_unread_notifications(company_id) when is_integer(company_id) do
    query =
      from n in Notification,
      where: n.viewed == false and
             (n.recipient_company_id == ^company_id)

    Repo.aggregate(query, :count)
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
