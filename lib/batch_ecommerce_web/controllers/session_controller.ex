defmodule BatchEcommerceWeb.SessionController do
  use BatchEcommerceWeb, :controller
  action_fallback BatchEcommerceWeb.FallbackController

  alias BatchEcommerce.{Accounts, Accounts.Guardian}

  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

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

  swagger_path :login do
    post "/api/login"
    summary "Fazer login"
    description "Autentica um usuário e retorna um token de acesso"
    produces "application/json"
    consumes "application/json"
    tag "Session"
    operation_id "login_user"
    
    parameter :credentials, :body, Schema.ref(:LoginParams), "Credenciais do usuário", required: true
    
    response 200, "OK", Schema.ref(:LoginResponse)
    response 401, "Unauthorized", Schema.ref(:ErrorCredencial)
    response 500, "Server Error"
  end

  swagger_path :logout do
    post "/api/logout"
    summary "Fazer logout"
    description "Encerra a sessão do usuário atual"
    produces "application/json"
    tag "Session"
    operation_id "logout_user"
    
    security [%{Bearer: []}]
    
    response 200, "OK", Schema.ref(:LogoutResponse)
    response 401, "Unauthorized"
    response 500, "Server Error"
  end

  # Definição dos schemas
  def swagger_definitions do
    %{
      # Parâmetros para login
      LoginParams: %{
        type: :object,
        properties: %{
          email: %{type: :string, description: "Email do usuário", example: "joao.silva@exemplo.com"},
          password: %{type: :string, description: "Senha do usuário", example: "Senha@123"}
        },
        required: [:email, :password]
      },
      
      # Resposta do login
      LoginResponse: %{
        type: :object,
        properties: %{
          data: %{
            type: :object,
            properties: %{
              id: %{type: :string, format: :uuid, description: "ID único do usuário", example: "6789598c-b26d-446f-bcd7-b4872d664129"},
              email: %{type: :string, description: "Email do usuário", example: "joao.silva@exemplo.com"},
              token: %{type: :string, description: "Token JWT de autenticação", example: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."}
            }
          }
        }
      },
      
      # Resposta do logout
      LogoutResponse: %{
        type: :object,
        properties: %{
          msg: %{type: :string, description: "Mensagem de sucesso", example: "Logged out"}
        }
      },

      ErrorCredencial: %{
        type: :object,
        properties: %{
          error: %{type: :string, description: "error Invalid credentials", example: "Invalid credentials"}
        }
      },
    }
  end
end
