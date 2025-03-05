defmodule BatchEcommerceWeb.CartController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.Cart

  action_fallback BatchEcommerceWeb.FallbackController

  def show(conn, _params) do
    case ShoppingCart.get_cart_by_user_uuid(conn.private.guardian_default_resource.id) do
      %Cart{} = cart ->
        conn
        |> put_status(:ok)
        |> render(:show, cart: cart)

      nil ->
        {:error, :bad_request}
    end
  end
end
