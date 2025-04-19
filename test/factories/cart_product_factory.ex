defmodule BatchEcommerce.Factories.CartProductFactory do
  alias BatchEcommerce.ShoppingCart.CartProduct

  defmacro __using__(_opts) do
    quote do
      def cart_product_factory do
        user = insert(:user)
        product = insert(:product)

        %CartProduct{
          price_when_carted: 0,
          quantity: 10,
          user_id: user.id,
          product_id: product.id
        }
      end
    end
  end
end