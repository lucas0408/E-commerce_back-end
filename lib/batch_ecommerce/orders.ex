defmodule BatchEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import BatchEcommerce.ShoppingCart, only: [list_cart_products: 0]
  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Order.Order
  alias BatchEcommerce.Order.OrderProduct

  def complete_order(user_id, shipping_cost) do
    cart_products = BatchEcommerce.ShoppingCart.get_cart_user(user_id)

    order =
      %Order{}
      |> Order.changeset(%{
        user_id: user_id,
        total_price: Decimal.add(BatchEcommerce.ShoppingCart.total_price_cart_product(cart_products), shipping_cost)
      })
      |>Repo.insert!()

    order_products =
      Enum.map(cart_products, fn item ->
        %OrderProduct{}
        |> OrderProduct.changeset(%{
          product_id: item.product_id,
          price: item.price_when_carted,
          quantity: item.quantity,
          order_id: order.id,
          status: "Preparando Pedido",
        
        })
        |>Repo.insert!()
      end)

      case BatchEcommerce.ShoppingCart.prune_cart_items(user_id) do
        {:ok, _} -> 
          {:ok, Repo.preload(order, order_products: [:product]) |> Repo.preload(user: [:addresses])}
        error -> 
          error
      end
  end
  
  def list_company_orders_paginated(company_id, page, per_page) do
    # Primeiro obtenha todos os IDs de produtos da empresa
    product_ids = Repo.all(
      from p in BatchEcommerce.Catalog.Product,
      where: p.company_id == ^company_id,
      select: p.id
    )


    # Agora busque todos os order_products para esses produtos
    query = from op in OrderProduct,
      join: p in assoc(op, :product),
      join: o in assoc(op, :order),
      join: u in assoc(o, :user),
      where: op.product_id in ^product_ids,
      preload: [product: p, order: {o, user: u}],
      order_by: [desc: op.inserted_at]

    # Executar a paginação
    result = Repo.paginate(query, page: page, page_size: per_page)
    
    result
  end

  def list_orders do
    Repo.all(OrderProduct) |> Repo.preload(:product)
  end

  def get_order!(user_id, id) do
    Order
    |> Repo.get_by!(id: id, user_id: user_id)
    |> Repo.preload(order_products: [:product]) |> Repo.preload(user: [:addresses])
  end
  
  def list_orders_by_user(user_id) do
    Repo.all(
      from o in Order,
        where: o.user_id == ^user_id,
        preload: [order_products: :product]
    )
  end

  def get_order_by_user_id!(user_id) do
    from(i in Order, where: i.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(order_products: [:product]) |> Repo.preload(user: [:addresses])
  end

  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
