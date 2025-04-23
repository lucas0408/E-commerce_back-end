defmodule BatchEcommerceWeb.CartControllerTest do
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.CatalogFixtures

  import BatchEcommerce.Factory

  alias BatchEcommerce.ShoppingCart.CartItem

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.Guardian

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup do
    cart_product = insert(:cart_product)
    %{cart_product: cart_product}
  end

  setup do
    invalid_attrs = %{params_for(:cart_product) | quantity: -1, }
    %{invalid_attrs: invalid_attrs}
  end

  setup do
    invalid_product_id_attrs = invalid_params_for(:cart_product, [:product_id])
    %{invalid_product_id_attrs: invalid_product_id_attrs}
  end



  describe "index" do
    setup [:create_session]

    test "lists all carts", %{conn: conn, cart_product: cart_product} do
      conn = get(conn, ~p"/api/cart_products")

      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") ==
               cart_product.id
    end
  end

  describe "create cart_item" do
    setup [:create_session]

    test "renders cart_item when data is valid", %{conn: conn} do
        
      cart_attrs = params_for(:cart_product, [user_id: conn.private.guardian_default_resource.id])

      conn =
        post(conn, ~p"/api/cart_products", cart_product: cart_attrs)

      response_data = json_response(conn, 201)["data"]
      
      assert response_data["price_when_carted"] == "#{cart_attrs.price_when_carted}"

      assert response_data["product_id"] == cart_attrs.product_id

      assert response_data["quantity"] == cart_attrs.quantity

      assert response_data["user_id"] == cart_attrs.user_id
      
    end

    test "renders errors when product is nil", %{conn: conn, invalid_product_id_attrs: invalid_product_id_attrs} do
      conn = post(conn, ~p"/api/cart_products", cart_product: invalid_product_id_attrs)
      assert json_response(conn, 404)["errors"] == %{"detail" => "Not Found"}
    end

    test "renders errors when data is invalid", %{conn: conn, invalid_attrs: invalid_attrs} do
      conn = post(conn, ~p"/api/cart_products", cart_product: invalid_attrs)
      assert json_response(conn, 422)["errors"] == %{"quantity" => ["must be greater than or equal to 0"]}
    end
  end

  describe "update cart_item" do
    setup [:create_session]

    test "renders cart_item when data is valid", %{
      conn: conn,
      cart_product: cart_product
    } do
      update_attrs = params_for(:cart_product, [user_id: cart_product.user_id, quantity: 23])
      conn = put(conn, ~p"/api/cart_products/#{cart_product}", cart_product: update_attrs)

      response_data = json_response(conn, 200)["data"]

      assert response_data["product_id"] == cart_product.product_id

      assert response_data["user_id"] == cart_product.user_id

      assert response_data["price_when_carted"] != cart_product.price_when_carted

      assert response_data["quantity"] != cart_product.quantity

      assert response_data["quantity"] == update_attrs.quantity
    end

    test "renders errors when data is invalid", %{conn: conn, cart_product: cart_product, invalid_attrs: invalid_attrs} do
      conn = put(conn, ~p"/api/cart_products/#{cart_product}", cart_product: invalid_attrs)
      assert json_response(conn, 422)["errors"] == %{"quantity" => ["must be greater than or equal to 0"]}
    end
  end

  describe "delete cart_item" do
    setup [:create_session]

    test "deletes chosen cart_item", %{conn: conn, cart_product: cart_product} do
      conn = delete(conn, ~p"/api/cart_products/#{cart_product}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/cart_products/#{cart_product}")
      assert conn.status == 404
    end
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
