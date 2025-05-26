defmodule BatchEcommerceWeb.CategoryController do
  use BatchEcommerceWeb, :controller

  use PhoenixSwagger

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Category

  action_fallback BatchEcommerceWeb.FallbackController

  swagger_path :index do
    get "/api/categories"
    summary "List categories"
    description "Retorna uma lista de todas as categorias cadastrados no sistema"
    produces "application/json"
    tag "Category"
    operation_id "list_categories"
    
    response 200, "OK", Schema.ref(:CategoriesListResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
  end

  swagger_path :create do
    post "/api/categories"
    summary "Add a categoria"
    description "Cria uma nova categoria ao sistema"
    produces "application/json"
    tag "Category"
    consumes "application/json"
    
    parameter :category, :body, Schema.ref(:CategoryParams), "Parâmetros da categoria", required: true
    
    response 201, "Created", Schema.ref(:CategorieResponse)
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :update do
    put "/api/categories/{id}"
    summary "Update a Category"
    description "Atualiza uma categoria existente com as informações fornecidas"
    produces "application/json"
    consumes "application/json"
    tag "Category"
    
    parameter :id, :path, :integer, "ID da categoria", required: true
    parameter :category, :body, Schema.ref(:CategoryParams), "Parâmetros de category", required: true
    
    response 200, "OK", Schema.ref(:CategorieResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/categories/{id}"
    summary "Excluir categoria"
    description "Exclui uma categoria de acordo com o id passado"
    produces "application/json"
    tag "Category"
    
    response 204, "No Content"
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end

  swagger_path :show do
    get "/api/categories/{id}"
    summary "Return a category by given id"
    description "Retorna informações detalhadas de uma categoria específica pelo ID"
    produces "application/json"
    
    parameter :id, :path, :integer, "ID da categoria", required: true
    
    response 200, "OK", Schema.ref(:CategorieResponse)
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end

  def index(conn, _params) do
    categories = Catalog.list_categories()

    conn
    |> put_status(:ok)
    |> render(:index, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    case Catalog.create_category(category_params) do
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/categories/#{category}")
        |> render(:show, category: category)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_category(id) do
      %Category{} = category ->
        conn
        |> put_status(:ok)
        |> render(:show, category: category)

      nil ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    with %Category{} = category_found <- Catalog.get_category(id),
         {:ok, category_updated} <-
           Catalog.update_category(category_found, category_params) do
      conn
      |> put_status(:ok)
      |> render(:show, category: category_updated)
    else
      nil ->
        {:error, :not_found}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Category{} = category_found <- Catalog.get_category(id),
         {:ok, _deleted_category} <- Catalog.delete_category(category_found) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def swagger_definitions do
    %{
      CategoryParams: swagger_schema do
        title "Parâmetros da categoria"
        description "Parâmetros para adicionar uma categoria ao sistema"
        properties do
          type :string, "nome da categotia", required: true
        end
        example %{
          "category" => %{
            "type" => "Bebidas"
          }
        }
      end,

      CategoriesListResponse: %{
        type: :object,
        properties: %{
          data: %{
            type: :array,
            items: %{
            }
          }
        },
        example: %{
          "data" => [
            %{
              "id" => 1,
              "type" => "Bebidas"
            },
            %{
              "id": 2,
              "type": "Vestuário"
            }
          ]
        }
      },

      CategorieResponse: swagger_schema do
        title "Resposta de category"
        description "Representação JSON de uma categoria"
        properties do
          data Schema.ref(:CategorieData)
        end
        example %{
          "data" => %{
            "id" => 1,
            "type" => "Bebidas"
          }
        }
      end,
      
      CategorieData: swagger_schema do
        properties do
          id :integer, "ID da categoria"
          type :string, "nome da categotia"
        end
      end
    }
  end
end
