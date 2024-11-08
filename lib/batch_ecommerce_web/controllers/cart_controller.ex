defmodule BatchEcommerceWeb.CartController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.Cart

  action_fallback BatchEcommerceWeb.FallbackController

  def show(conn, _params) do
    cart = ShoppingCart.get_cart_by_user_uuid(conn.private.guardian_default_resource.id)
    conn
    |> put_status(:ok)
    |> render(:show, cart: cart)
  end
end
