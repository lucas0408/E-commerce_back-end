defmodule BatchEcommerceWeb.ProductController do
  use BatchEcommerceWeb, :controller

  use PhoenixSwagger

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  action_fallback BatchEcommerceWeb.FallbackController

  swagger_path :index do
    get "/api/products"
    summary "Lista todos os produtos"
    description "Retorna uma lista com todos os produtos cadastrados"
    produces "application/json"
    
    response 200, "OK", Schema.ref(:ProductsResponse)
  end

  swagger_path :create do
    post "/api/products"
    summary "Cria um novo produto"
    description "Cria um novo produto com as informações fornecidas"
    produces "application/json"
    consumes "application/json"
    
    parameter :product, :body, Schema.ref(:ProductParams), "Parâmetros do produto", required: true
    
    response 201, "Created", Schema.ref(:ProductResponse)
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :update do
    put "/api/products/{id}"
    summary "Atualiza um produto existente"
    description "Atualiza um produto existente com as informações fornecidas"
    produces "application/json"
    consumes "application/json"
    
    parameter :id, :path, :integer, "ID do produto", required: true
    parameter :product, :body, Schema.ref(:ProductParams), "Parâmetros do produto", required: true
    
    response 200, "OK", Schema.ref(:ProductResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :show do
    get "/api/products/{id}"
    summary "Obtém um produto específico"
    description "Retorna informações detalhadas de um produto específico pelo ID"
    produces "application/json"
    
    parameter :id, :path, :integer, "ID do produto", required: true
    
    response 200, "OK", Schema.ref(:ProductResponse)
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/products/{id}"
    summary "Remove um produto"
    description "Remove permanentemente um produto pelo ID"
    
    parameter :id, :path, :integer, "ID do produto", required: true
    
    response 204, "No Content"
    response 401, "Unauthorized"
    response 403, "Forbidden"
    response 400, "Bad Request"
  end

  def index(conn, _params) do
    products = Catalog.list_products()

    conn
    |> put_status(:ok)
    |> render(:index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/products/#{product}")
        |> render(:show, product: product)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_product(id) do
      %Product{} = product ->
        conn
        |> put_status(:ok)
        |> render(:show, product: product)

      nil ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with %Product{} = product_found <- Catalog.get_product(id),
         {:ok, product_updated} <-
           Catalog.update_product(product_found, product_params) do
      render(conn, :show, product: product_updated)
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Product{} = product_found <- Catalog.get_product(id),
         {:ok, _deleted_product} <-
           Catalog.delete_product(product_found) do
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
      ProductParams: swagger_schema do
        title "Parâmetros do Produto"
        description "Parâmetros para criar ou atualizar um produto"
        properties do
          name :string, "Nome do produto", required: true
          description :string, "Descrição do produto", required: true
          company_id :integer, "ID da empresa", required: true
          categories :array, "IDs das categorias", items: :integer, required: true
          image_url :string, "URL da imagem do produto", required: true
          price :number, "Preço do produto", format: :float, required: true
          stock_quantity :integer, "Quantidade em estoque", required: true
        end
        example %{
          "product" => %{
            "name" => "nome_produto_teste",
            "description" => "teste_descrição",
            "company_id" => 9,
            "categories" => [1, 2],
            "image_url" => "http://localhost:9000/batch-bucket/43985685-289d-4837-9a43-2dd172eb9a77-product_image.jpg",
            "price" => 12.3,
            "stock_quantity" => 30
          }
        }
      end,

      ProductsResponse: swagger_schema do
        title "Resposta de Lista de Produtos"
        description "Lista com todos os produtos cadastrados"
        properties do
          data Schema.array(:ProductData)
        end
        example %{
          "data" => [
            %{
              "id" => 8,
              "name" => "name_product_test_9",
              "description" => "teste_descrição",
              "company_id" => 2,
              "categories" => %{
                "data" => []
              },
              "image_url" => "http://localhost:9000/batch-bucket/43985685-289d-4837-9a43-2dd172eb9a77-product_image.jpg",
              "price" => "12.3",
              "stock_quantity" => 30
            },
            %{
              "id" => 9,
              "name" => "outro_produto",
              "description" => "descrição do produto",
              "company_id" => 3,
              "categories" => %{
                "data" => [
                  %{"id" => 1, "type" => "Eletrônicos"}
                ]
              },
              "image_url" => "http://localhost:9000/batch-bucket/outro-produto.jpg",
              "price" => "99.9",
              "stock_quantity" => 15
            }
          ]
        }
      end,
      
      ProductResponse: swagger_schema do
        title "Resposta de Produto"
        description "Representação JSON de um produto"
        properties do
          data Schema.ref(:ProductData)
        end
        example %{
          "data" => %{
            "id" => 1,
            "name" => "nome_produto_teste",
            "description" => "teste_descrição",
            "company_id" => 9,
            "price" => 12.3,
            "stock_quantity" => 30,
            "image_url" => "http://localhost:9000/batch-bucket/43985685-289d-4837-9a43-2dd172eb9a77-product_image.jpg",
            "categories" => %{
              "data" => [
                %{"id" => 1, "type" => "Eletrônicos"},
                %{"id" => 2, "type" => "Smartphones"}
              ]
            }
          }
        }
      end,
      
      ProductData: swagger_schema do
        properties do
          id :integer, "ID do produto"
          name :string, "Nome do produto"
          description :string, "Descrição do produto"
          company_id :integer, "ID da empresa"
          price :number, "Preço do produto", format: :float
          stock_quantity :integer, "Quantidade em estoque"
          image_url :string, "URL da imagem do produto"
          categories Schema.ref(:CategoryResponse)
        end
      end,
      
      CategoryResponse: swagger_schema do
        properties do
          data Schema.array(:CategoryData)
        end
        example %{
          "data" => [
            %{"id" => 1, "type" => "Eletrônicos"},
            %{"id" => 2, "type" => "Smartphones"}
          ]
        }
      end,
      
      CategoryData: swagger_schema do
        properties do
          id :integer, "ID da categoria"
          type :string, "Tipo da categoria"
        end
      end
    }
  end
end
