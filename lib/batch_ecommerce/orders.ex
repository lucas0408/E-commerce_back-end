defmodule BatchEcommerce.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Order.Order
  alias BatchEcommerce.Order.OrderProduct

  #Estudar Ecto.Multi
  def complete_order(user_id, shipping_cost) do
    cart_products = BatchEcommerce.ShoppingCart.get_cart_user(user_id)
    
    # Criar o changeset da order
    order_changeset = 
      %Order{}
      |> Order.changeset(%{
        user_id: user_id,
        status_payment: "Pendente",
        total_price: Decimal.add(BatchEcommerce.ShoppingCart.total_price_cart_product(cart_products), shipping_cost)
      })

    multi = 
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:order, order_changeset)
      |> add_order_products_to_multi(cart_products)
      |> Ecto.Multi.run(:update_stock, fn _repo, changes ->
        update_stock_for_products(cart_products)
      end)
      |> Ecto.Multi.run(:create_notifications, fn _repo, changes ->
        create_notifications_for_products(cart_products)
      end)
      |> Ecto.Multi.run(:prune_cart, fn _repo, _changes ->
        BatchEcommerce.ShoppingCart.prune_cart_items(user_id)
      end)

    case Repo.transaction(multi) do
      {:ok, %{order: order}} ->
        
        preloaded_order = 
          order
          |> Repo.preload(order_products: [:product])
          |> Repo.preload(user: [:addresses])
        {:ok, preloaded_order}
      
      {:error, name, value, _changes_so_far} ->
        IO.inspect(value)
        {:error, {name, value}}
    end
  end

  # Função auxiliar para adicionar order_products ao Multi
  defp add_order_products_to_multi(multi, cart_products) do
    IO.inspect(multi)
    cart_products
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {item, index}, acc_multi ->
      Ecto.Multi.insert(acc_multi, {:order_product, index}, fn %{order: order} ->
        %OrderProduct{}
        |> OrderProduct.changeset(%{
          product_id: item.product_id,
          price: item.price_when_carted,
          quantity: item.quantity,
          status: "Preparando Pedido",
          order_id: order.id
        })
      end)
    end)
  end

  # Função auxiliar para atualizar estoque
  defp update_stock_for_products(cart_products) do
    try do
      Enum.each(cart_products, fn item ->
        case BatchEcommerce.Catalog.remove_stock(item.quantity, item.product_id) do
          {:ok, _} -> :ok
          {:error, reason} -> throw({:stock_error, reason})
        end
      end)
      {:ok, :stock_updated}
    catch
      {:stock_error, reason} -> {:error, reason}
    end
  end

  # Função auxiliar para criar notificações
  defp create_notifications_for_products(cart_products) do
    try do
      notifications = 
        Enum.map(cart_products, fn item ->
          product = BatchEcommerce.Catalog.get_product(item.product_id)
          case BatchEcommerce.Accounts.create_notification(%{
            title: "Novo pedido",
            body: "#{item.quantity} #{product.name} foram pedidos",
            recipient_company_id: product.company_id,
          }) do
            {:ok, notification} -> notification
            {:error, reason} -> throw({:notification_error, reason})
          end
        end)
      
      {:ok, notifications}
    catch
      {:notification_error, reason} -> {:error, reason}
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
    case get_order(order_id) do
      nil ->
        {:error, :not_found}

      order ->
        order
        |> Order.changeset(attrs)
        |> Repo.update()
    end
  end

  def update_order_product_status(order_product_id, new_status, company_id)  when is_integer(company_id) do
    order_product = update_order_status(order_product_id, new_status)
    case BatchEcommerce.Accounts.create_notification(%{
      title: "Pedido",
      body: "Peido nº #{order_product_id} #{new_status}",
      recipient_company_id: company_id,
    }) do
      {:ok, notification} ->
        {:ok, notification}
      error ->
        {:error, error}
    end
    order_product
  end

  def update_order_product_status(order_product_id, new_status, user_id) when is_binary(user_id) do
    order_product = update_order_status(order_product_id, new_status)
    case BatchEcommerce.Accounts.create_notification(%{
      title: "Pedido",
      body: "Pedido nº #{order_product_id} #{new_status}",
      recipient_user_id: user_id,
    }) do
      {:ok, _notification} ->
        {:ok, _notification}
      error ->
        {:error, error}
    end
    order_product
  end

  def update_order_status(order_product_id, new_status) do
    case Repo.get(OrderProduct, order_product_id) do
      nil ->
        {:error, :not_found}

      order_product ->
        if new_status == "Cancelado" do
          BatchEcommerce.Catalog.return_stock(order_product.quantity, order_product.product_id)
        end
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
