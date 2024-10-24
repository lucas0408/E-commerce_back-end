defmodule BatchEcommerceWeb.CartController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.Cart

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    IO.inspect(conn.private.guardian_default_resource.cart)
    carts = ShoppingCart.list_carts()
    render(conn, :index, carts: carts)
  end

  def create(conn, %{"cart" => cart_params}) do
    with {:ok, %Cart{} = cart} <- ShoppingCart.create_cart(cart_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/carts/#{cart}")
      |> render(:show, cart: cart)
    end
  end

  def show(conn, %{"id" => id}) do
    cart = ShoppingCart.get_cart!(id)
    render(conn, :show, cart: cart)
  end

  def update(conn, %{"id" => id, "cart" => cart_params}) do
    cart = ShoppingCart.get_cart!(id)

    with {:ok, %Cart{} = cart} <- ShoppingCart.update_cart(cart, cart_params) do
      render(conn, :show, cart: cart)
    end
  end

  def delete(conn, %{"id" => id}) do
    cart = ShoppingCart.get_cart!(id)

    with {:ok, %Cart{}} <- ShoppingCart.delete_cart(cart) do
      send_resp(conn, :no_content, "")
    end
  end
end
