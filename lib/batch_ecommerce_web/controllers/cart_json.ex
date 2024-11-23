defmodule BatchEcommerceWeb.CartJSON do
  alias BatchEcommerce.ShoppingCart.Cart

  @doc """
  Renders a single cart.
  """
  def show(%{cart: cart}) do
    %{data: data(cart)}
  end

  defp data(%Cart{} = cart) do
    %{
      id: cart.id,
      user_uuid: cart.user_id,
      cart_items: BatchEcommerceWeb.CartItemJSON.index(cart.items)
    }
  end
end
