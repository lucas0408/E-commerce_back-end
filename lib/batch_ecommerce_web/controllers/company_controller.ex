defmodule BatchEcommerceWeb.CompanyController do
  use BatchEcommerceWeb, :controller

  use PhoenixSwagger

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Company

  action_fallback BatchEcommerceWeb.FallbackController

  swagger_path :index do
    get "/api/companies"
    summary "Lista todas as empresas"
    description "Retorna uma lista com todas as empresas cadastradas"
    produces "application/json"
    
    response 200, "OK", Schema.ref(:CompaniesListResponse)
    response 401, "Unauthorized"
  end

  swagger_path :create do
    post "/api/companies"
    summary "Cria uma nova empresa"
    description "Cria uma nova empresa com os dados fornecidos"
    produces "application/json"
    consumes "application/json"
    
    parameter :company, :body, Schema.ref(:CompanyParams), "Parâmetros da empresa", required: true
    
    response 201, "Created", Schema.ref(:CompanyResponse)
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :show do
    get "/api/companies/{id}"
    summary "Obtém uma empresa específica"
    description "Retorna informações detalhadas de uma empresa específica pelo ID"
    produces "application/json"
    
    parameter :id, :path, :integer, "ID da empresa", required: true
    
    response 200, "OK", Schema.ref(:CompanyResponse)
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end

  swagger_path :update do
    put "/api/companies/{id}"
    summary "Atualiza uma empresa existente"
    description "Atualiza uma empresa existente com as informações fornecidas"
    produces "application/json"
    consumes "application/json"
    
    parameter :id, :path, :integer, "ID da empresa", required: true
    parameter :company, :body, Schema.ref(:CompanyParams), "Parâmetros da empresa", required: true
    
    response 200, "OK", Schema.ref(:CompanyResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/companies/{id}"
    summary "Remove uma empresa"
    description "Remove permanentemente uma empresa pelo ID"
    
    parameter :id, :path, :integer, "ID da empresa", required: true
    
    response 204, "No Content"
    response 401, "Unauthorized"
    response 403, "Forbidden"
    response 400, "Bad Request"
  end

  def index(conn, _params) do
    companies = Accounts.list_companies()
    conn
    |> put_status(:ok)
    |> render(:index, companies: companies)
  end

  def create(conn, %{"company" => company_params}) do
    user_id = conn.private.guardian_default_resource.id

    company_params = Map.put(company_params, "user_id", user_id)

    with {:ok, %Company{} = company} <- Accounts.create_company(company_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/companies/#{company}")
      |> render(:show, company: company)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Company{} = company <- Accounts.get_company(id) do
      conn
      |> put_status(:ok)
      |> render(:show, company: company)
    else
      nil -> {:error, :not_found}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

  def update(conn, %{"id" => id, "company" => company_params}) do
    with %Company{} = company <- Accounts.get_company(id),
    {:ok, %Company{} = company} <- Accounts.update_company(company, company_params) do
      conn
      |> put_status(:ok)
      |> render(:show, company: company)
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Company{} = company <- Accounts.get_company(id),
    {:ok, %Company{}} <- Accounts.delete_company(company) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

   def swagger_definitions do
    %{
      CompanyParams: swagger_schema do
        title "Parâmetros da Empresa"
        description "Parâmetros para criar ou atualizar uma empresa"
        properties do
          name :string, "Nome da empresa", required: true
          cnpj :string, "CNPJ da empresa", required: true
          email :string, "Email de contato da empresa", required: true
          phone_number :string, "Número de telefone da empresa", required: true
          user_id :string, "ID do usuário proprietário", format: :uuid
          addresses :array, "Endereços da empresa", items: Schema.ref(:AddressParams), required: true
        end
        example %{
          "company" => %{
            "name" => "Empresa Exemplo LTDA",
            "cnpj" => "12345678000199",
            "email" => "contato@empresaexemplo.com",
            "phone_number" => "+5511999999999",
            "user_id" => "89d91017-7a89-4f14-a365-5013b7720278",
            "addresses" => [
              %{
                "cep" => "01310930",
                "uf" => "SP",
                "city" => "São Paulo",
                "district" => "Bela Vista",
                "address" => "Avenida Paulista",
                "complement" => "Conjunto 101",
                "home_number" => "1000"
              },
              %{
                "cep" => "04543011",
                "uf" => "SP",
                "city" => "São Paulo",
                "district" => "Vila Olímpia",
                "address" => "Rua do Rocio",
                "complement" => "Andar 8",
                "home_number" => "313"
              }
            ]
          }
        }
      end,

      AddressParams: swagger_schema do
        title "Parâmetros de Endereço"
        description "Parâmetros para criar ou atualizar um endereço"
        properties do
          cep :string, "CEP", required: true
          uf :string, "Unidade Federativa (Estado)", required: true
          city :string, "Cidade", required: true
          district :string, "Bairro", required: true
          address :string, "Logradouro", required: true
          complement :string, "Complemento"
          home_number :string, "Número", required: true
        end
      end,

      CompaniesListResponse: %{
        type: :object,
        properties: %{
          data: %{
            type: :array,
            items: %{
              "$ref": "#/definitions/Company"
            }
          }
        },
        example: %{
          "data" => [
            %{
              "id" => 2,
              "name" => "Empresa Exemplo LTDA",
              "cnpj" => "12345678000199",
              "email" => "contato@empresaexemplo.com",
              "phone_number" => "+5511999999999",
              "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
              "addresses" => %{
                "data" => [
                  %{
                    "id" => 4,
                    "address" => "Avenida Paulista",
                    "cep" => "01310930",
                    "city" => "São Paulo",
                    "complement" => "Conjunto 101",
                    "district" => "Bela Vista",
                    "home_number" => "1000",
                    "uf" => "SP"
                  },
                  %{
                    "id" => 5,
                    "address" => "Rua do Rocio",
                    "cep" => "04543011",
                    "city" => "São Paulo",
                    "complement" => "Andar 8",
                    "district" => "Vila Olímpia",
                    "home_number" => "313",
                    "uf" => "SP"
                  }
                ]
              },
              "products" => %{
                "data" => []
              }
            }
          ]
        }
      },

      CompanyResponse: swagger_schema do
        title "Resposta de Empresa"
        description "Representação JSON de uma empresa"
        properties do
          data Schema.ref(:CompanyData)
        end
        example %{
          "data" => %{
            "id" => 2,
            "name" => "Empresa Exemplo LTDA",
            "cnpj" => "12345678000199",
            "email" => "contato@empresaexemplo.com",
            "phone_number" => "+5511999999999",
            "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
            "addresses" => %{
              "data" => [
                %{
                  "id" => 4,
                  "address" => "Avenida Paulista",
                  "cep" => "01310930",
                  "city" => "São Paulo",
                  "complement" => "Conjunto 101",
                  "district" => "Bela Vista",
                  "home_number" => "1000",
                  "uf" => "SP"
                },
                %{
                  "id" => 5,
                  "address" => "Rua do Rocio",
                  "cep" => "04543011",
                  "city" => "São Paulo",
                  "complement" => "Andar 8",
                  "district" => "Vila Olímpia",
                  "home_number" => "313",
                  "uf" => "SP"
                }
              ]
            },
            "products" => %{
              "data" => []
            }
          }
        }
      end,
      
      Company: swagger_schema do
        title "Empresa"
        description "Representação JSON de uma empresa"
        properties do
          id :integer, "ID da empresa"
          name :string, "Nome da empresa"
          cnpj :string, "CNPJ da empresa"
          email :string, "Email de contato da empresa"
          phone_number :string, "Número de telefone da empresa"
          user_id :string, "ID do usuário proprietário", format: :uuid
          addresses Schema.ref(:AddressesResponse), "Endereços da empresa"
          products Schema.ref(:ProductsResponse), "Produtos da empresa"
        end
      end,
      
      CompanyData: swagger_schema do
        properties do
          id :integer, "ID da empresa"
          name :string, "Nome da empresa"
          cnpj :string, "CNPJ da empresa"
          email :string, "Email de contato da empresa"
          phone_number :string, "Número de telefone da empresa"
          user_id :string, "ID do usuário proprietário", format: :uuid
          addresses Schema.ref(:AddressesResponse), "Endereços da empresa"
          products Schema.ref(:ProductsResponse), "Produtos da empresa"
        end
      end,
      
      AddressesResponse: swagger_schema do
        properties do
          data Schema.array(:AddressData), "Lista de endereços"
        end
      end,
      
      ProductsResponse: swagger_schema do
        properties do
          data Schema.array(:ProductData), "Lista de produtos"
        end
      end,
      
      AddressData: swagger_schema do
        properties do
          id :integer, "ID do endereço"
          cep :string, "CEP"
          uf :string, "Unidade Federativa (Estado)"
          city :string, "Cidade"
          district :string, "Bairro"
          address :string, "Logradouro"
          complement :string, "Complemento"
          home_number :string, "Número"
        end
      end
    }
  end
end
