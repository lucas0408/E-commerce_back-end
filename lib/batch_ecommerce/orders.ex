defmodule BatchEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Orders.Order

  @doc """
  Returns the list of orders.

  ## Examples

      iex> list_orders()
      [%Order{}, ...]

  """
  def complete_order(conn) do
    cart =
      conn.private.guardian_default_resource
      |> Repo.preload(cart: [items: [:product]])
      |> Map.get(:cart)

    line_items =
      Enum.map(cart.items, fn item ->
        %BatchEcommerce.Orders.LineItem{}
        |> BatchEcommerce.Orders.LineItem.changeset(%{
          product_id: item.product_id,
          price: item.product.price,
          quantity: item.quantity
        })
      end)

    order =
      %Order{}
      |> Order.changeset(%{
        user_uuid: cart.user_id,
        total_price: BatchEcommerce.ShoppingCart.total_cart_price(cart),
        line_items: line_items
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:order, order)
    |> Ecto.Multi.run(:prune_cart, fn _repo, _changes ->
      BatchEcommerce.ShoppingCart.prune_cart_items(cart)
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

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(user_uuid, id) do
    Order
    |> Repo.get_by!(id: id, user_uuid: user_uuid)
    |> Repo.preload(line_items: [:product])
  end

  @doc """
  Deletes a order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
