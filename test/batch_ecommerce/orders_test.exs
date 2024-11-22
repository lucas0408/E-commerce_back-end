defmodule BatchEcommerce.OrdersTest do
  use BatchEcommerce.DataCase
  use Phoenix.ConnTest

  alias BatchEcommerce.Orders
  import BatchEcommerce.ShoppingCartFixtures
  import BatchEcommerce.AccountsFixtures
  alias BatchEcommerce.Orders.Order
  import BatchEcommerce.OrdersFixtures

  @endpoint BatchEcommerce.Endpoint

  describe "orders" do
    setup do
      conn = build_conn()
      user = user_fixture()

      authenticated_conn =
        conn
        |> Guardian.Plug.sign_in(BatchEcommerce.Accounts.Guardian, user)
        |> Guardian.Plug.put_current_resource(user)

      cart_item_fixture(%{}, authenticated_conn)

      {:ok, conn: authenticated_conn, user: user}
    end

    @invalid_attrs %{user_uuid: nil, total_price: nil}

    test "list_orders/0 returns all orders", %{conn: conn} do
      order = order_fixture(conn)
      found_order = Orders.list_orders() |> List.first()
      assert found_order.id == order.id
    end

    test "get_order!/1 returns the order with given id", %{conn: conn, user: user} do
      order = order_fixture(conn)
      assert Orders.get_order!(user.id, order.id).id == order.id
    end

    test "complete_order/1 with valid data creates a order", %{conn: conn} do
      user_uuid = conn.private[:guardian_default_resource].id

      assert {:ok, %Order{} = order} = Orders.complete_order(conn)
      assert order.user_uuid == user_uuid
      assert order.total_price == Decimal.new("125.00")
    end
  end

end
