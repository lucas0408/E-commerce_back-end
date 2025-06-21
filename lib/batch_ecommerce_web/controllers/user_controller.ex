defmodule BatchEcommerceWeb.UserController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.{User, Guardian}

  action_fallback BatchEcommerceWeb.FallbackController

  #TODO: remover após fase de testes
  def index(conn, _params) do
    users = Accounts.list_users()

    conn
    |> put_status(:ok)
    |> render(:index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    IO.inspect(user_params)
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:create, user: user, token: token)
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

        {:error, _reason} ->
          {:error, :bad_request}
    end
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      %User{} = user ->
        conn
        |> put_status(:ok)
        |> render(:show, user: user)

      nil ->
        {:error, :bad_request}
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    with %User{} = user <- Accounts.get_user(id),
         {:ok, %User{} = user_updated} <- Accounts.update_user(user, user_params) do
      conn
      |> put_status(:ok)
      |> render(:show_update, user: user_updated)
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %User{} = user <- Accounts.get_user(id),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end
end
