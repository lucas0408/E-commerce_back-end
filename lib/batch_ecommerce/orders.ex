defmodule BatchEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import BatchEcommerce.ShoppingCart, only: [list_cart_products: 0]
  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Order.Order
  alias BatchEcommerce.Order.OrderProduct

  def complete_order(user_id) do
    cart_products = BatchEcommerce.ShoppingCart.get_cart_user(user_id)

    order =
      %Order{}
      |> Order.changeset(%{
        user_id: user_id,
        total_price: BatchEcommerce.ShoppingCart.total_price_cart_product(cart_products)
      })
      |>Repo.insert!()

    order_products =
      Enum.map(cart_products, fn item ->
        %OrderProduct{}
        |> OrderProduct.changeset(%{
          product_id: item.product_id,
          price: item.price_when_carted,
          quantity: item.quantity,
          order_id: order.id
        })
        |>Repo.insert!()
      end)

      case BatchEcommerce.ShoppingCart.prune_cart_items(user_id) do
        {:ok, _} -> 
          {:ok, Repo.preload(order, order_products: [:product])}
        error -> 
          error
      end
  end

  def list_orders do
    Repo.all(Order) |> Repo.preload(order_products: [:product])
  end

  def get_order!(user_id, id) do
    Order
    |> Repo.get_by!(id: id, user_id: user_id)
    |> Repo.preload(order_products: [:product])
  end

  def get_order_by_user_id!(user_id) do
    from(i in Order, where: i.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(order_products: [:product])
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
