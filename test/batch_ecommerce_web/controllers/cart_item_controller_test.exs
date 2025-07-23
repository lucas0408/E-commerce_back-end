<<<<<<< HEAD

=======
defmodule BatchEcommerceWeb.CartItemControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.ShoppingCartFixtures

  alias BatchEcommerce.ShoppingCart.CartItem

  @create_attrs %{
    price_when_carted: "120.5",
    quantity: 42
  }
  @update_attrs %{
    price_when_carted: "456.7",
    quantity: 43
  }
  @invalid_attrs %{price_when_carted: nil, quantity: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all cart_items", %{conn: conn} do
      conn = get(conn, ~p"/api/cart_items")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create cart_item" do
    test "renders cart_item when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/cart_items", cart_item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/cart_items/#{id}")

      assert %{
               "id" => ^id,
               "price_when_carted" => "120.5",
               "quantity" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/cart_items", cart_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update cart_item" do
    setup [:create_cart_item]

    test "renders cart_item when data is valid", %{conn: conn, cart_item: %CartItem{id: id} = cart_item} do
      conn = put(conn, ~p"/api/cart_items/#{cart_item}", cart_item: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/cart_items/#{id}")

      assert %{
               "id" => ^id,
               "price_when_carted" => "456.7",
               "quantity" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, cart_item: cart_item} do
      conn = put(conn, ~p"/api/cart_items/#{cart_item}", cart_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete cart_item" do
    setup [:create_cart_item]

    test "deletes chosen cart_item", %{conn: conn, cart_item: cart_item} do
      conn = delete(conn, ~p"/api/cart_items/#{cart_item}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/cart_items/#{cart_item}")
      end
    end
  end

  defp create_cart_item(_) do
    cart_item = cart_item_fixture()
    %{cart_item: cart_item}
  end
end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
