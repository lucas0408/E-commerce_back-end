defmodule BatchEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import BatchEcommerce.ShoppingCart, only: [list_cart_products: 0]
  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Orders.Order
  alias BatchEcommerce.Orders.OrderProduct

  def complete_order(_conn) do
    cart_products = list_cart_products()

    order_products =
      Enum.map(cart_products, fn item ->
        %OrderProduct{}
        |> OrderProduct.changeset(%{
          product_id: item.product_id,
          price: item.product.price,
          quantity: item.quantity
        })
      end)

    order =
      %Order{}
      |> Order.changeset(%{
        user_uuid: order_products.user_uuid,
        total_price: 0,
        order_products: order_products
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:order, order)
    |> Ecto.Multi.run(:prune_cart, fn _repo, _changes ->
      BatchEcommerce.ShoppingCart.prune_cart_items(order_products)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{order: order}} -> {:ok, order}
      {:error, name, value, _changes_so_far} -> {:error, {name, value}}
    end
  end

  def list_orders do
    Repo.all(Order)
  end

  def get_order!(user_uuid, id) do
    Order
    |> Repo.get_by!(id: id, user_uuid: user_uuid)
    |> Repo.preload(line_items: [:product])
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
