defmodule BatchEcommerce.Factories.OrderFactory do
  alias BatchEcommerce.Order.Order

  defmacro __using__(_opts) do
    quote do
      def order_factory do
        user = insert(:user)

        %Order{
          user_id: user.id,
          total_price: 1230.00
        }
      end
    end
  end
end