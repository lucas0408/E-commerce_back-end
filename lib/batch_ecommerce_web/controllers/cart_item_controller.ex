defmodule BatchEcommerceWeb.CartItemController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.CartItem

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    cart_items = ShoppingCart.list_cart_items()
    render(conn, :index, cart_items: cart_items)
  end

  def create(conn, %{"cart_item" => cart_item_params}) do
    with {:ok, %CartItem{} = cart_item} <- ShoppingCart.add_item_to_cart(cart_item_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/cart_items/#{cart_item}")
      |> render(:show, cart_item: cart_item)
    end
  end

  def show(conn, %{"id" => id}) do
    cart_item = ShoppingCart.get_cart_item!(id)
    render(conn, :show, cart_item: cart_item)
  end

  def update(conn, %{"id" => id, "cart_item" => cart_item_params}) do
    cart_item = ShoppingCart.get_cart_item!(id)

    with {:ok, %CartItem{} = cart_item} <- ShoppingCart.update_cart_item(cart_item, cart_item_params) do
      render(conn, :show, cart_item: cart_item)
    end
  end

  def delete(conn, %{"id" => id}) do
    cart_item = ShoppingCart.get_cart_item!(id)

    with {:ok, %CartItem{}} <- ShoppingCart.delete_cart_item(cart_item) do
      send_resp(conn, :no_content, "")
    end
  end
end
