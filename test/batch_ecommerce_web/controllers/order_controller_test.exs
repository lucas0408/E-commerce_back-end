defmodule BatchEcommerceWeb.OrderControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.OrdersFixtures

  alias BatchEcommerce.Orders.Order

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.{User, Guardian}

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
               "user_uuid" => user_uuid
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
