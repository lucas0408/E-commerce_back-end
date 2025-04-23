defmodule BatchEcommerceWeb.OrderControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.OrdersFixtures

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.Guardian

  alias BatchEcommerce.Orders

  import BatchEcommerce.Factory

  @create_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_session_order]

    test "lists all orders", %{conn: conn, order: order} do
      conn = get(conn, ~p"/api/orders")

      response_data = json_response(conn, 200)["data"] |> Enum.at(0)

      assert response_data |> Map.get("id") == order.id

      assert Decimal.equal?(Decimal.new(Map.get(response_data, "total_price")), order.total_price)

      assert response_data |> Map.get("user_id") == order.user_id

    end
  end

  describe "create order" do
    setup [:create_session]

    test "renders order when data is valid", %{conn: conn} do
      cart_products = insert_list(2, :cart_product, [user_id: user_id = conn.private.guardian_default_resource.id])
      conn = post(conn, ~p"/api/orders", order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      total_price = Enum.reduce(cart_products, Decimal.new(0), fn cart_product, acc -> 
        Decimal.add(acc, cart_product.price_when_carted)
      end)

      response_data = json_response(conn, 200)["data"]
      expected_data = %{
        "id" => id,
        "total_price" => to_string(Decimal.round(total_price,2)),
        "user_id" => user_id
      }
      assert Map.take(response_data, Map.keys(expected_data)) == expected_data
    end
  end

  defp create_session(%{conn: conn}) do
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}")}
  end


  defp create_session_order(%{conn: conn}) do
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    cart_products = insert_list(2, :cart_product, [user_id: user_id = conn.private.guardian_default_resource.id])
    {:ok, order} = Orders.complete_order(conn.private.guardian_default_resource.id)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), order: order}
  end
end
