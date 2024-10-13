defmodule BatchEcommerceWeb.UserController do
  use BatchEcommerceWeb, :controller
  require IEx
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.{User, Address, Guardian}

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    users = Repo.preload(Accounts.list_users(), [:address])
    render(conn, :index, users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <-
           Accounts.create_user(user_params),
         {:ok, token, _claims} = Guardian.encode_and_sign(user) do
      user = Repo.preload(user, :address)

      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:create, user: user, token: token)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id) |> Repo.preload(:address)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    %User{}
    |> Accounts.change_user(user_params |> Map.put("address_id", 1))

    Accounts.change_address(%Address{}, user_params["address"])

    user = Accounts.get_user!(id)
    address = Accounts.get_address!(user.address_id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params),
         Accounts.update_address(address, user_params["address"]) do
      user = Repo.preload(user, :address)

      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    address = Accounts.get_address!(user.address_id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      Accounts.delete_address(address)
      send_resp(conn, :no_content, "")
    end
  end
end
