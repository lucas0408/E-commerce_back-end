defmodule BatchEcommerceWeb.SessionController do
  use BatchEcommerceWeb, :controller
  action_fallback BatchEcommerceWeb.FallbackController

  alias BatchEcommerce.{Accounts, Accounts.Guardian}

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Accounts.authenticate_user(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> render(:user_token, user: user, token: token)
    else
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> json(%{msg: "Logged out"})
  end
end
