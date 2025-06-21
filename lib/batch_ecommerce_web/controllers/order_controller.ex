defmodule BatchEcommerceWeb.OrderController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Orders

  alias BatchEcommerce.Order.Order

  alias NimbleCSV.Spreadsheet, as: CSV

  action_fallback BatchEcommerceWeb.FallbackController

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
end
