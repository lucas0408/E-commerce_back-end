defmodule BatchEcommerceWeb.OrderController do
  use BatchEcommerceWeb, :controller

  use PhoenixSwagger
  
  alias BatchEcommerce.Orders

  alias BatchEcommerce.Order.Order

  alias NimbleCSV.Spreadsheet, as: CSV

  action_fallback BatchEcommerceWeb.FallbackController

  swagger_path :create do
    post "/api/orders"
    summary "Cria um novo pedido"
    description "Cria um novo pedido de acordo com os shopping_cart cadastrado no sistema"
    produces "application/json"
    consumes "application/json"
    
    response 201, "Created", Schema.ref(:OrderResponse)
    response 401, "Unauthorized"
    response 422, "Unprocessable Entity"
  end

  swagger_path :index do
    get "/api/orders"
    summary "Lista todos os pedidos"
    description "Retorna uma lista com todos os pedidos cadastrados"
    produces "application/json"
    
    response 200, "OK", Schema.ref(:OrdersListResponse)
    response 401, "Unauthorized"
  end

  swagger_path :show do
    get "/api/orders/{id}"
    summary "Obtém um pedido específico"
    description "Retorna informações detalhadas de um pedido específico pelo ID"
    produces "application/json"
    
    parameter :id, :path, :integer, "ID do pedido", required: true
    
    response 200, "OK", Schema.ref(:OrderResponse)
    response 401, "Unauthorized"
    response 400, "Bad Request"
  end

  @csv_headers [
    "name",
    "cpf",
    "cep",
    "uf",
    "city",
    "district",
    "address",
    "home number",
    "total price",
    "Total cart itens"
  ]

  def index(conn, _params) do
    orders = Orders.list_orders()

    conn
    |> put_status(:ok)
    |> render(:index, orders: orders)
  end
  
  def export_stream(conn, _params) do
    stream =
      Stream.resource(
        fn -> 0 end,
        fn cursor ->
          entries = Orders.list_orders()

          if Enum.empty?(entries) do
            {:halt, entries}
          else
            {entries, List.last(entries).id}
          end
        end,
        fn _ -> :ok end
      )

    {:ok, conn} =
      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=ordert_entries.csv")
      |> send_chunked(200)
      |> chunk(CSV.dump_to_iodata([@csv_headers]))

    stream
    |> Stream.map(&format_timesheet_entry/1)
    |> CSV.dump_to_stream()
    |> Enum.reduce_while(conn, fn line, conn ->
      case chunk(conn, line) do
        {:ok, conn} ->
          {:cont, conn}
        {:error, "closed"} ->
          {:halt, conn}
      end
    end)
  end

  defp format_timesheet_entry(%Order{} = order) do
    [
      order.user.name,
      order.user.cpf,
      order.addresses.cep,
      order.addresses.uf,
      order.addresses.city,
      order.addresses.district,
      order.addresses.address,
      order.addresses.home_number,
      Decimal.round(order.total_price, 2),
      length(order.order_products)
    ]
  end

  def create(conn, _params) do
    case Orders.complete_order(conn.private.guardian_default_resource.id) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/products/#{order}")
        |> render(:show, order: order)
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(conn.private[:guardian_default_resource].id, id)

    conn
    |> put_status(:ok)
    |> render(:show, order: order)
  end

  def swagger_definitions do
    %{
      OrdersListResponse: %{
        type: :object,
        properties: %{
          data: %{
            type: :array,
            items: %{
              "$ref": "#/definitions/Order"
            }
          }
        },
        example: %{
          "data" => [
            %{
              "id" => 1,
              "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
              "total_price" => "17499.95",
              "order_products" => [
                %{
                  "id" => 1,
                  "price" => "17499.950000",
                  "quantity" => 5,
                  "product_id" => 1,
                  "order_id" => 1,
                  "inserted_at" => "2025-05-07T22:35:59Z",
                  "updated_at" => "2025-05-07T22:35:59Z",
                  "product" => %{
                    "id" => 1,
                    "name" => "Smartphone Galaxy S21",
                    "price" => "3499.99",
                    "stock_quantity" => 50,
                    "image_url" => "https://example.com/images/galaxy-s21.jpg",
                    "description" => "Celular potente",
                    "company_id" => 1,
                    "inserted_at" => "2025-05-07T21:24:20Z",
                    "updated_at" => "2025-05-07T21:24:20Z"
                  }
                }
              ]
            }
          ]
        }
      },

      OrderResponse: swagger_schema do
        title "Resposta de Pedido"
        description "Representação JSON de um pedido"
        properties do
          data Schema.ref(:OrderData)
        end
        example %{
          "data" => %{
            "id" => 1,
            "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
            "total_price" => "17499.95",
            "order_products" => [
              %{
                "id" => 1,
                "price" => "17499.950000",
                "quantity" => 5,
                "product_id" => 1,
                "order_id" => 1,
                "inserted_at" => "2025-05-07T22:35:59Z",
                "updated_at" => "2025-05-07T22:35:59Z",
                "product" => %{
                  "id" => 1,
                  "name" => "Smartphone Galaxy S21",
                  "price" => "3499.99",
                  "stock_quantity" => 50,
                  "image_url" => "https://example.com/images/galaxy-s21.jpg",
                  "description" => "Celular potente",
                  "company_id" => 1,
                  "inserted_at" => "2025-05-07T21:24:20Z",
                  "updated_at" => "2025-05-07T21:24:20Z"
                }
              }
            ]
          }
        }
      end,
      
      Order: swagger_schema do
        title "Pedido"
        description "Representação JSON de um pedido"
        properties do
          id :integer, "ID do pedido"
          user_id :string, "ID do usuário", format: :uuid
          total_price :string, "Valor total do pedido"
          order_products Schema.array(:OrderProductData), "Produtos do pedido"
        end
        example %{
          "id" => 1,
          "user_id" => "633fb773-aabb-43df-9b09-f277e3a8b93f",
          "total_price" => "17499.95",
          "order_products" => [
            %{
              "id" => 1,
              "price" => "17499.950000",
              "quantity" => 5,
              "product_id" => 1,
              "order_id" => 1,
              "inserted_at" => "2025-05-07T22:35:59Z",
              "updated_at" => "2025-05-07T22:35:59Z",
              "product" => %{
                "id" => 1,
                "name" => "Smartphone Galaxy S21",
                "price" => "3499.99",
                "stock_quantity" => 50,
                "image_url" => "https://example.com/images/galaxy-s21.jpg",
                "description" => "Celular potente",
                "company_id" => 1,
                "inserted_at" => "2025-05-07T21:24:20Z",
                "updated_at" => "2025-05-07T21:24:20Z"
              }
            }
          ]
        }
      end,
      
      OrderData: swagger_schema do
        properties do
          id :integer, "ID do pedido"
          user_id :string, "ID do usuário", format: :uuid
          total_price :string, "Valor total do pedido"
          order_products Schema.array(:OrderProductData), "Produtos do pedido"
        end
      end,
      
      OrderProductData: swagger_schema do
        properties do
          id :integer, "ID do item do pedido"
          price :string, "Preço total do item"
          quantity :integer, "Quantidade do produto"
          product_id :integer, "ID do produto"
          order_id :integer, "ID do pedido"
          inserted_at :string, "Data de criação", format: "date-time"
          updated_at :string, "Data de atualização", format: "date-time"
          product Schema.ref(:OrderProductDetails), "Detalhes do produto"
        end
      end,
      
      OrderProductDetails: swagger_schema do
        properties do
          id :integer, "ID do produto"
          name :string, "Nome do produto"
          price :string, "Preço unitário do produto"
          stock_quantity :integer, "Quantidade em estoque"
          image_url :string, "URL da imagem do produto"
          description :string, "Descrição do produto"
          company_id :integer, "ID da empresa"
          inserted_at :string, "Data de criação", format: "date-time"
          updated_at :string, "Data de atualização", format: "date-time"
        end
      end
    }
  end

end
