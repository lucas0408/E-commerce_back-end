defmodule BatchEcommerceWeb.OrderController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Orders
  alias BatchEcommerce.Orders.Order
  alias BatchEcommerce.Repo

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    orders = Orders.list_orders()
    conn
    |> put_status(:ok)
    |> render(:index, orders: orders)
  end

  def create(conn, _params) do
    case Orders.complete_order(conn) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/products/#{order}")
        |> render(:show, order: order)

      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    order = Orders.get_order!(conn.private[:guardian_default_resource].id, id)
    conn
    |> put_status(:ok)
    |> render(:show, order: order)
  end
end
