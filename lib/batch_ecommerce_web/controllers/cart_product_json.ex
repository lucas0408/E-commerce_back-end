defmodule BatchEcommerceWeb.CartProductJSON do
  alias BatchEcommerce.ShoppingCart.CartProduct
  alias BatchEcommerce.ShoppingCart

  def index(%{cart_products: cart_products}) do
    %{data: for(cart_item <- cart_products, do: data(cart_item))}
  end

  @doc """
  Renders a single cart_item.
  """
  def show(%{cart_products: cart_product}) do
    %{data: data(cart_product)}
  end

  defp data(%CartProduct{} = cart_item) do
    %{
      id: cart_item.id,
      product_id: cart_item.product_id,
      price_when_carted: cart_item.price_when_carted,
      quantity: cart_item.quantity,
      product:
        BatchEcommerceWeb.ProductJSON.show(%{
          product: ShoppingCart.preload_product(cart_item).product
        })
    }
  end
end
