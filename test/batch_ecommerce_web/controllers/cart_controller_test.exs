defmodule BatchEcommerceWeb.CartControllerTest do
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.CatalogFixtures

  import BatchEcommerce.ShoppingCartFixtures

  alias BatchEcommerce.ShoppingCart.CartItem

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.Guardian

  @create_attrs %{
    "product_id" => nil,
    quantity: "42"
  }
  @update_attrs %{
    "product_id" => nil,
    quantity: "43"
  }
  @invalid_attrs %{"product_id" => nil, quantity: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_cart_item]

    test "lists all carts", %{conn: conn, cart_item: cart_item} do
      conn = get(conn, ~p"/api/cart")

      assert json_response(conn, 200)["data"]["cart_items"] |> Enum.at(0) |> Map.get("id") ==
               cart_item.id
    end
  end

  describe "create cart_item" do
    setup [:create_session]

    test "renders cart_item when data is valid", %{conn: conn, user: user} do
      product = product_fixture_assoc()

      cart_id = BatchEcommerce.ShoppingCart.create_cart(%{user_id: user.id})

      create_attrs = %{
        "quantity" => "42",
        "product_id" => product.id
      }

      conn =
        post(conn, ~p"/api/cart_items", cart_item: create_attrs)

      assert %{"id" => _id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/cart/{1}")

      assert json_response(conn, 200)["data"]["cart_items"]["data"]
             |> Enum.at(0)
             |> Map.get("product_id") ==
               product.id
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/cart_items", cart_item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update cart_item" do
    setup [:create_cart_item]

    test "renders cart_item when data is valid", %{
      conn: conn,
      cart_item: %CartItem{id: id} = cart_item
    } do
      update_attrs = %{@update_attrs | "product_id" => cart_item.product_id}
      conn = put(conn, ~p"/api/cart_items/#{cart_item}", cart_item: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/cart")

      assert json_response(conn, 200)["data"]["cart_items"] |> Enum.at(0) |> Map.get("product_id") ==
               update_attrs["product_id"]
    end

    test "renders errors when data is invalid", %{conn: conn, cart_item: cart_item} do
      conn = put(conn, ~p"/api/cart_items/#{cart_item}", cart_item: @invalid_attrs)
      assert json_response(conn, 404)["errors"] != %{}
    end
  end

  describe "delete cart_item" do
    setup [:create_cart_item]

    test "deletes chosen cart_item", %{conn: conn, cart_item: cart_item} do
      conn = delete(conn, ~p"/api/cart_items/#{cart_item}")
      assert response(conn, 204)
    end
  end

  defp create_cart_item(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    cart_item = cart_item_fixture(%{}, conn)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), cart_item: cart_item}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
