defmodule BatchEcommerce.OrdersTest do
  use BatchEcommerce.DataCase, async: true

  import Phoenix.ConnTest

  alias BatchEcommerce.Orders
  alias BatchEcommerce.Order.Order
  alias BatchEcommerce.Order.OrderProduct
  alias BatchEcommerce.ShoppingCart.CartProduct

  import BatchEcommerce.Factory

  describe "orders" do

    test "complete_order/1 with valid data creates a order" do
      user = insert(:user)

      list_cart_products = insert_list(5, :cart_product, [user_id: user.id])

      assert {:ok, %Order{} = order} = Orders.complete_order(user.id)

      assert order.user_id == user.id

      assert Decimal.equal?(order.total_price, Enum.reduce(list_cart_products, Decimal.new(0), fn cart_product, acc -> 
                                    Decimal.add(acc, cart_product.price_when_carted)
                                end)
              )

      
      assert Enum.zip(order.order_products, list_cart_products)
      |> Enum.all?(fn {%OrderProduct{price: price1, product_id: product_id1, quantity: quantity1}, 
                      %CartProduct{price_when_carted: price2, product_id: product_id2, quantity: quantity2}} ->
                      product_id1 == product_id2 and quantity1 == quantity2 and Decimal.equal?(price1, price2) end)


    end

    test "list_orders/0 return all orders" do
      normalize_order = fn order ->
        %{order | total_price: Decimal.normalize(order.total_price)}
      end

      orders = insert_list(3, :order) |> normalize_orders()
      db_orders = Orders.list_orders() |> normalize_orders()

      assert orders == db_orders
    end

    test "get_order!/2 returns the order with given id and user_id" do

      order = insert(:order) |> Repo.preload(order_products: [:product]) |> normalize_order()

      get_order = Orders.get_order!(order.user_id, order.id) |> normalize_order()

      assert order == get_order
    end

    defp normalize_orders(orders) do
      Enum.map(orders, fn order ->
        %{order | total_price: Decimal.normalize(order.total_price)}
      end)
    end

    defp normalize_order(order) do
      %{order | total_price: Decimal.normalize(order.total_price)}
    end

    test "get_order_by_user_id!/1 returns the order with given user_id" do
      user = insert(:user)

      list_cart_products = insert_list(5, :cart_product, [user_id: user.id])

      assert {:ok, %Order{} = order1} = Orders.complete_order(user.id)

      assert [order1] |> normalize_orders() == Orders.get_order_by_user_id!(user.id) |> normalize_orders()

      list_cart_products = insert_list(5, :cart_product, [user_id: user.id])

      assert {:ok, %Order{} = order2} = Orders.complete_order(user.id)

      assert [order1, order2] |> normalize_orders() == Orders.get_order_by_user_id!(user.id) |> normalize_orders()
    end

    test "delete_order/1 deltete order" do
      order = insert(:order)

      Orders.delete_order(order)

      assert Orders.get_order_by_user_id!(order.user_id) == []
    end
  end
end
