defmodule BatchEcommerceWeb.CartProductController do
  use BatchEcommerceWeb, :controller

  use PhoenixSwagger

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.CartProduct

  action_fallback BatchEcommerceWeb.FallbackController

  swagger_path :index do
    get "/api/cart_products"
    summary "List carts"
    description "Retorna uma lista de todos os carrinhos cadastrados no sistema"
    produces "application/json"
    tag "Cart"
    operation_id "list_cart"
    
    response 200, "OK", Schema.ref(:CartsListResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
  end

  swagger_path :create do
    post "/api/cart_products"
    summary "Add a cart product"
    description "Cria uma nova entrada de produto no carrinho do usuário"
    produces "application/json"
    tag "Cart"
    consumes "application/json"
    
    parameter :cart_product, :body, Schema.ref(:CartProductParams), "Parâmetros do produto no carrinho", required: true
    
    response 201, "Created", Schema.ref(:CartProductResponse)
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :update do
    put "/api/cart_products/{id}"
    summary "Update a cart product"
    description "Atualiza um cart_product existente com as informações fornecidas"
    produces "application/json"
    consumes "application/json"
    tag "Cart"
    
    parameter :id, :path, :integer, "ID do cart_product", required: true
    parameter :product, :body, Schema.ref(:CartProductParams), "Parâmetros de cart_product", required: true
    
    response 200, "OK", Schema.ref(:CartProductResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :get_by_user do
    get "/api/cart_products/user/{user_id}"
    summary "Return a cart product by user_id"
    description "retorna o carrinho de acordo com o id de usuário passado"
    produces "application/json"
    tag "Cart"
    
    response 200, "OK", Schema.ref(:CartsListResponse)
    response 400, "Bad Request"
    response 401, "Unauthorized"
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete "/api/cart_products/{id}"
    summary "Delete a cart_product"
    description "Exclui um cart_product de acordo com o id passado"
    produces "application/json"
    tag "Cart"
    
    response 204, "No Content"
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end


  def index(conn, _params) do
    cart_products = ShoppingCart.list_cart_products()

    conn
    |> put_status(:ok)
    |> render(:index, cart_products: cart_products)
  end

  def show(conn, %{"id" => id}) do
    case ShoppingCart.get_cart_product(id) do
      %CartProduct{} = product ->
        conn
        |> put_status(:ok)
        |> render(:show, product: product)

      nil ->
        {:error, :not_found}
    end
  end

  def get_by_user(conn, %{"user_id" => user_id}) do
    cart_products = ShoppingCart.get_cart_user(user_id)
    
    conn
    |> put_status(:ok)
    |> render(:index, cart_products: cart_products)
  end

  def create(conn, %{"cart_product" => cart_product_params}) do
    with {:ok, %CartProduct{} = cart_product} <- ShoppingCart.create_cart_prodcut(conn.private.guardian_default_resource.id, cart_product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/cart_products/#{cart_product}")
      |> render(:show, cart_product: cart_product)
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      error -> error
    end
  end

  def update(conn, %{"id" => id, "cart_product" => cart_product_params}) do
    with %CartProduct{} = cart_product <- ShoppingCart.get_cart_product(id),
         {:ok, %CartProduct{} = cart_product} <-
           ShoppingCart.update_cart_product(cart_product, cart_product_params) do
      conn
      |> put_status(:ok)
      |> render(:show, cart_product: cart_product)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %CartProduct{} = cart_product <- ShoppingCart.get_cart_product(id),
         {:ok, %CartProduct{}} <- ShoppingCart.delete_cart_product(cart_product) do
      send_resp(conn, :no_content, "")
    end
  end

def swagger_definitions do
    %{
      CartProductParams: swagger_schema do
        title "Parâmetros do Produto no Carrinho"
        description "Parâmetros para adicionar um produto ao carrinho"
        properties do
          quantity :integer, "Quantidade do produto", required: true
          product_id :integer, "ID do produto", required: true
          user_id :string, "ID do usuário (UUID)", format: :uuid
        end
        example %{
          "cart_product" => %{
            "quantity" => 5,
            "product_id" => 1,
            "user_id" => "89d91017-7a89-4f14-a365-5013b7720278"
          }
        }
      end,

      CartsListResponse: %{
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
              "product" => %{
                "data" => %{
                  "id" => 1,
                  "name" => "Smartphone Galaxy S21",
                  "description" => "Celular potente",
                  "company_id" => 1,
                  "categories" => %{
                    "data" => [
                      %{"id" => 1, "type" => "Eletrônicos"}
                    ]
                  },
                  "image_url" => "https://example.com/images/galaxy-s21.jpg",
                  "price" => "3499.99",
                  "stock_quantity" => 50
                }
              },
              "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
              "product_id" => 1,
              "quantity" => 5,
              "price_when_carted" => "17499.95"
            }
          ]
        }
      },

      CartProductResponse: swagger_schema do
        title "Resposta de Produto no Carrinho"
        description "Representação JSON de um produto no carrinho"
        properties do
          data Schema.ref(:CartProductData)
        end
        example %{
          "data" => %{
            "id" => 1,
            "product" => %{
              "data" => %{
                "id" => 1,
                "name" => "Smartphone Galaxy S21",
                "description" => "Celular potente",
                "company_id" => 1,
                "categories" => %{
                  "data" => [
                    %{"id" => 1, "type" => "Eletrônicos"}
                  ]
                },
                "image_url" => "https://example.com/images/galaxy-s21.jpg",
                "price" => "3499.99",
                "stock_quantity" => 50
              }
            },
            "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
            "product_id" => 1,
            "quantity" => 5,
            "price_when_carted" => "17499.95"
          }
        }
      end,
      
      CartProductData: swagger_schema do
        properties do
          id :integer, "ID do produto no carrinho"
          product Schema.ref(:ProductResponse), "Detalhes do produto"
          user_id :string, "ID do usuário", format: :uuid
          product_id :integer, "ID do produto"
          quantity :integer, "Quantidade do produto"
          price_when_carted :string, "Preço total quando adicionado ao carrinho"
        end
      end
    }
  end
    
end
