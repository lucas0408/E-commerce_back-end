defmodule BatchEcommerceWeb.OrderJSON do
  alias BatchEcommerce.Order.Order

  @doc """
  Renders a list of orders.
  """
  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  @doc """
  Renders a single order.
  """
  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(%Order{} = order) do
    IO.inspect(order)

    %{
      id: order.id,
      user: order.user,
      total_price: Decimal.round(order.total_price, 2),
      order_products: order.order_products
    }
  end
end
