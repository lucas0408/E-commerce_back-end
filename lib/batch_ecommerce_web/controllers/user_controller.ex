defmodule BatchEcommerceWeb.UserController do
  use BatchEcommerceWeb, :controller
  alias BatchEcommerce.Accounts.{User, Guardian}
  alias BatchEcommerce.Accounts

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    IO.inspect(conn)
    case Accounts.list_users() do
      [] ->
        {:error, :not_found}

      users ->
        conn
        |> put_status(:found)
        |> render(:index, users: users)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} = Guardian.encode_and_sign(user) do

      BatchEcommerce.ShoppingCart.create_cart(%{user_id: user.id})
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:create, user: user, token: token)
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      %User{} = user ->
        conn
        |> put_status(:found)
        |> render(:show, user: user)

      nil ->
        {:error, :not_found}

      _unkown_error ->
        {:error, :internal_server_error}
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    with %User{} = user <- Accounts.get_user(id),
         {:ok, %User{} = user_updated} <- Accounts.update_user(user, user_params) do
      conn
      |> put_status(:ok)
      |> render(:show, user: user_updated)
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end

  end

  def delete(conn, %{"id" => id}) do
    with %User{} = user <- Accounts.get_user(id),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      _unkown_error -> {:error, :internal_server_error}
    end
  end
end
