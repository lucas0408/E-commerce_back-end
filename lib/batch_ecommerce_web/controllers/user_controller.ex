defmodule BatchEcommerceWeb.UserController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.{User, Guardian}

  action_fallback BatchEcommerceWeb.FallbackController

  import Plug.Conn.Status, only: [code: 1]
  use PhoenixSwagger

  swagger_path :index do
    get "/api/users"
    summary "Listar usuários"
    description "Retorna uma lista de todos os usuários cadastrados no sistema"
    produces "application/json"
    tag "Users"
    operation_id "list_users"
    
    response 200, "OK", Schema.ref(:UsersListResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
  end

  def index(conn, _params) do
    users = Accounts.list_users()

    conn
    |> put_status(:ok)
    |> render(:index, users: users)
  end

  swagger_path :create do
    post "/api/users"
    summary "Criar novo usuário"
    description "Cria um novo usuário no sistema e retorna os dados com token de autenticação"
    produces "application/json"
    consumes "application/json"
    tag "Users"
    operation_id "create_user"
    
    parameter :user, :body, Schema.ref(:UserParams), "Dados do usuário", required: true
    
    response 201, "Created", Schema.ref(:UserCreateResponse)
    response 400, "Bad Request"
    response 422, "Unprocessable Entity", Schema.ref(:ErrorList)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:create, user: user, token: token)
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  swagger_path :show do
    get "/api/users/{id}"
    summary "Obter detalhes de um usuário"
    description "Retorna todos os dados de um usuário específico"
    produces "application/json"
    tag "Users"
    operation_id "show_user"
    
    parameter :id, :path, :string, "ID do usuário", required: true, example: "6789598c-b26d-446f-bcd7-b4872d664129"
    
    response 200, "OK", Schema.ref(:UserResponse)
    response 401, "Unauthorized"
    response 400, "Bad Request"
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

  swagger_path :update do
    put "/api/users/{id}"
    summary "Atualizar usuário"
    description "Atualiza os dados de um usuário existente, permitindo modificar qualquer campo exceto o ID"
    produces "application/json"
    consumes "application/json"
    tag "Users"
    operation_id "update_user"
    
    parameter :id, :path, :string, "ID do usuário", required: true, example: "6789598c-b26d-446f-bcd7-b4872d664129"
    parameter :user, :body, Schema.ref(:UserParams), "Dados do usuário para atualização", required: true
    
    response 200, "OK", Schema.ref(:UserResponse)
    response 400, "Bad Request"
    response 422, "Unprocessable Entity", Schema.ref(:ErrorList)
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

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/users/{id}"
    summary "Excluir usuário"
    description "Remove um usuário do sistema"
    tag "Users"
    operation_id "delete_user"
    
    parameter :id, :path, :string, "ID do usuário", required: true, example: "6789598c-b26d-446f-bcd7-b4872d664129"
    
    response 204, "No Content"
    response 401, "Unauthorized"
    response 400, "Bad Request"
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

  # Definição dos schemas
def swagger_definitions do
  %{

    UserResponse: %{
      type: :object,
      properties: %{
        data: %{
          "$ref": "#/definitions/User"
        }
      }
    },
    UsersListResponse: %{
      type: :object,
      properties: %{
        data: %{
          type: :array,
          items: %{
            "$ref": "#/definitions/User"
          }
        }
      }
    },
    # Parâmetros para criação do usuário
    UserParams: %{
      type: :object,
      properties: %{
        user: %{
          type: :object,
          properties: %{
            cpf: %{type: :string, description: "CPF do usuário", example: "12345678901"},
            name: %{type: :string, description: "Nome completo do usuário", example: "João da Silva"},
            email: %{type: :string, description: "Email do usuário", example: "joao.silva@exemplo.com"},
            phone_number: %{type: :string, description: "Número de telefone", example: "11987654321"},
            birth_date: %{type: :string, format: :date, description: "Data de nascimento", example: "1990-01-15"},
            password: %{type: :string, description: "Senha do usuário", example: "Senha@123"},
            addresses: %{
              type: :array,
              items: %{
                "$ref": "#/definitions/Address"
              }
            }
          },
          required: [:cpf, :name, :email, :phone_number, :birth_date, :password]
        }
      },
      required: [:user]
    },
    
    # Resposta da criação do usuário
    UserCreateResponse: %{
      type: :object,
      properties: %{
        data: %{
          type: :object,
          properties: %{
            id: %{type: :string, format: :uuid, description: "ID único do usuário", example: "3d33d3e7-dd93-44a6-bf88-f6a4986e762b"},
            name: %{type: :string, description: "Nome completo do usuário", example: "João da Silva"},
            token: %{type: :string, description: "Token JWT de autenticação", example: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."},
            email: %{type: :string, description: "Email do usuário", example: "joao.silva@exemplo.com"},
            phone_number: %{type: :string, description: "Número de telefone", example: "11987654321"},
            addresses: %{
              type: :object,
              properties: %{
                data: %{
                  type: :array,
                  items: %{
                    "$ref": "#/definitions/AddressWithId"
                  }
                }
              }
            },
            birth_date: %{type: :string, format: :date, description: "Data de nascimento", example: "1990-01-15"},
            cpf: %{type: :string, description: "CPF do usuário", example: "12345678901"}
          }
        }
      }
    },

    User: %{
      type: :object,
      properties: %{
            id: %{type: :string, format: :uuid, description: "ID único do usuário", example: "3d33d3e7-dd93-44a6-bf88-f6a4986e762b"},
            cpf: %{type: :string, description: "CPF do usuário", example: "12345678901"},
            name: %{type: :string, description: "Nome completo do usuário", example: "João da Silva"},
            email: %{type: :string, description: "Email do usuário", example: "joao.silva@exemplo.com"},
            phone_number: %{type: :string, description: "Número de telefone", example: "11987654321"},
            birth_date: %{type: :string, format: :date, description: "Data de nascimento", example: "1990-01-15"},
            password: %{type: :string, description: "Senha do usuário (não deve ser retornada nas respostas reais)", example: "Senha@123"},
            addresses: %{
              type: :object,
              properties: %{
                data: %{
                  type: :array,
                  items: %{
                    "$ref": "#/definitions/AddressWithId"
                  }
                }
              }
            },
      },
          required: [:cpf, :name, :email, :phone_number, :birth_date]
        
    },
    Address: %{
      type: :object,
      properties: %{
        cep: %{type: :string, description: "CEP", example: "01311-000"},
        uf: %{type: :string, description: "UF", example: "SP"},
        city: %{type: :string, description: "Cidade", example: "São Paulo"},
        district: %{type: :string, description: "Bairro", example: "Bela Vista"},
        address: %{type: :string, description: "Logradouro", example: "Avenida Paulista"},
        complement: %{type: :string, description: "Complemento", example: "Apartamento 123"},
        home_number: %{type: :string, description: "Número", example: "1578"}
      },
      required: [:cep, :uf, :city, :district, :address, :home_number]
    },
    
    AddressWithId: %{
      type: :object,
      properties: %{
        id: %{type: :integer, description: "ID do endereço", example: 4},
        cep: %{type: :string, description: "CEP", example: "01311-000"},
        uf: %{type: :string, description: "UF", example: "SP"},
        city: %{type: :string, description: "Cidade", example: "São Paulo"},
        district: %{type: :string, description: "Bairro", example: "Bela Vista"},
        address: %{type: :string, description: "Logradouro", example: "Avenida Paulista"},
        complement: %{type: :string, description: "Complemento", example: "Apartamento 123"},
        home_number: %{type: :string, description: "Número", example: "1578"}
      },
      required: [:cep, :uf, :city, :district, :address, :home_number]
    },

    ErrorList: %{
      type: :object,
      properties: %{
        errors: %{
          type: :object,
          properties: %{
            email: %{
              type: :array,
              items: %{type: :string, description: "Descrição de erro do email", example: "Already in use"}
            },
            cpf: %{
              type: :array,
              items: %{type: :string, description: "Descrição de erro do cpf", example: "Already in use"}
            },
            phone_number: %{
              type: :array,
              items: %{type: :string, description: "Descrição de erro do email", example: "Enter a valid phone number"}
            },
          }
        }
      }
    }
  }

  end
end
