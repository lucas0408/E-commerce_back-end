defmodule BatchEcommerceWeb.CartProductController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.ShoppingCart.CartProduct

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    cart_products = ShoppingCart.list_cart_products()

    conn
    |> put_status(:ok)
    |> render(:index, cart_products: cart_products)
  end

  def show(conn, %{"id" => id}) do
    case ShoppingCart.get_cart_product(id) do
      %CartProduct{} = product ->
        conn
        |> put_status(:ok)
        |> render(:show, product: product)

      nil ->
        {:error, :not_found}
    end
  end

  def get_by_user(conn, %{"user_id" => user_id}) do
    cart_products = ShoppingCart.get_cart_user(user_id)

    conn
    |> put_status(:ok)
    |> render(:index, cart_products: cart_products)
  end

  def create(conn, %{"cart_product" => cart_product_params}) do
    with {:ok, %CartProduct{} = cart_product} <- ShoppingCart.create_cart_prodcut(conn.private.guardian_default_resource.id, cart_product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/cart_products/#{cart_product}")
      |> render(:show, cart_product: cart_product)
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      error -> error
    end
  end

  def update(conn, %{"id" => id, "cart_product" => cart_product_params}) do
    with %CartProduct{} = cart_product <- ShoppingCart.get_cart_product(id),
         {:ok, %CartProduct{} = cart_product} <-
           ShoppingCart.update_cart_product(cart_product, cart_product_params) do
      conn
      |> put_status(:ok)
      |> render(:show, cart_product: cart_product)
    end
  end

  def delete(conn, %{"id" => id}) do
    with %CartProduct{} = cart_product <- ShoppingCart.get_cart_product(id),
         {:ok, %CartProduct{}} <- ShoppingCart.delete_cart_product(cart_product) do
      send_resp(conn, :no_content, "")
    end
  end
end
