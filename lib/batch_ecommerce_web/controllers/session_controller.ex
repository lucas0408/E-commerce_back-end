defmodule BatchEcommerceWeb.SessionController do
  use BatchEcommerceWeb, :controller
  action_fallback BatchEcommerceWeb.FallbackController

  alias BatchEcommerce.{Accounts}
  alias BatchEcommerceWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Conta criada com sucesso!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Senha atualizada com sucesso!")
  end

  def create(conn, params) do
    create(conn, params, "Bem-vindo(a) de volta!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      conn
      |> put_flash(:error, "E-mail ou senha inválidos!")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, "Sessão encerrada com sucesso!")
    |> UserAuth.log_out_user()
  end
end
