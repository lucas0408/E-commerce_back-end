<<<<<<< HEAD
defmodule BatchEcommerceWeb.OrderControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.OrdersFixtures

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.Guardian

  import BatchEcommerce.ShoppingCartFixtures

  @create_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_session_order]

    test "lists all orders", %{conn: conn} do
      order = order_fixture(conn)
      conn = get(conn, ~p"/api/orders")
      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == order.id
    end
  end

  describe "create order" do
    setup [:create_session_order]

    test "renders order when data is valid", %{conn: conn} do
      user_uuid = conn.private[:guardian_default_resource].id
      conn = post(conn, ~p"/api/orders", order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "total_price" => "125.000000",
               "user_uuid" => ^user_uuid
             } = json_response(conn, 200)["data"]
    end
  end

  defp create_session_order(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    cart_item_fixture(%{}, conn)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}")}
  end
end
=======
defmodule BatchEcommerceWeb.OrderControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.OrdersFixtures

  alias BatchEcommerce.Orders.Order

  @create_attrs %{
    user_uuid: "7488a646-e31f-11e4-aace-600308960662",
    total_price: "120.5"
  }
  @update_attrs %{
    user_uuid: "7488a646-e31f-11e4-aace-600308960668",
    total_price: "456.7"
  }
  @invalid_attrs %{user_uuid: nil, total_price: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get(conn, ~p"/api/orders")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "total_price" => "120.5",
               "user_uuid" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "total_price" => "456.7",
               "user_uuid" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete(conn, ~p"/api/orders/#{order}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/orders/#{order}")
      end
    end
  end

  defp create_order(_) do
    order = order_fixture()
    %{order: order}
  end
end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
