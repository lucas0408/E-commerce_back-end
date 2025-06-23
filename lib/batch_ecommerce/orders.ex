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
        status_payment: "Peendente",
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
  
  def list_company_orders_paginated(company_id, page, per_page, opts \\ []) do
    status = opts[:status] || ""
    customer = opts[:customer] || ""

    # Obter IDs de produtos da empresa
    product_ids = Repo.all(
      from p in BatchEcommerce.Catalog.Product,
      where: p.company_id == ^company_id,
      select: p.id
    )

    # Query base
    base_query = from op in OrderProduct,
      join: p in assoc(op, :product),
      join: o in assoc(op, :order),
      join: u in assoc(o, :user),
      where: op.product_id in ^product_ids,
      preload: [product: p, order: {o, user: u}],
      order_by: [desc: op.inserted_at]

    # Aplicar filtros
    query = 
      if status != "" do
        from [op, p, o, u] in base_query,
        where: op.status == ^status
      else
        base_query
      end

    query =
      if customer != "" do
        from [op, p, o, u] in query,
        where: ilike(u.name, ^"%#{customer}%") or ilike(u.email, ^"%#{customer}%")
      else
        query
      end

    # Executar paginação
    Repo.paginate(query, page: page, page_size: per_page)
  end

  def update_order(order_id, attrs) do
    case Repo.get(Order, order_id) do
      nil ->
        {:error, :not_found}
        
      order ->
        order
        |> Order.changeset(attrs)
        |> Repo.update()
    end
  end

  def update_order_product_status(order_product_id, new_status) do
    case Repo.get(OrderProduct, order_product_id) do
      nil ->
        {:error, :not_found}
        
      order_product ->
        order_product
        |> OrderProduct.changeset(%{status: new_status})
        |> Repo.update()
        |> case do
            {:ok, order_product} ->
              order_product
            {:error, changeset} ->
              changeset
          end
    end
  end

  def list_orders do
    Repo.all(OrderProduct) |> Repo.preload(:product)
  end

  def list_orders_by_user(user_id) do
    Repo.all(
      from o in Order,
        where: o.user_id == ^user_id,
        preload: [order_products: :product]
    )
  end

  def get_order(id) do
    Repo.get(Order, id)
  end

  def get_order_product(id) do
    Repo.get(OrderProduct, id)
  end


  def delete_order(%Order{} = order) do
    Repo.delete(order)
  end
end
