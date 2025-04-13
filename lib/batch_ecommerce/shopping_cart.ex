defmodule BatchEcommerce.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.ShoppingCart.CartProduct

  def list_cart_products, do: Repo.all(CartProduct) |> preload_product()

  def create_cart_prodcut(id, cart_item_params) do
    product_id = Map.get(cart_item_params, "product_id")

    product = BatchEcommerce.Catalog.get_product(product_id)

    quantity = cart_item_params["quantity"] || "0"

    price_when_carted = Decimal.mult(product.price, quantity)

    attrs = %{
      quantity: quantity,
      price_when_carted: price_when_carted,
      user_id: id,
      product_id: product.id
    }

    %CartProduct{}
    |> CartProduct.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, cart_product} ->
        {:ok, preload_product(cart_product)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_cart_product(id) do
    case Repo.get(CartProduct, id) do
      nil ->
        {:error, :not_found}

      cart_product ->
        preload_product(cart_product)
    end
  end

  def preload_product(item_cart) do
    Repo.preload(item_cart, product: [:categories])
  end

  def update_cart_product(%CartProduct{} = cart_product, cart_product_params) do
    case cart_product_params["product_id"] do
      nil ->
        {:error, :not_found}

      product_id ->
        case BatchEcommerce.Catalog.get_product(product_id) do
          nil ->
            {:error, :not_found}

          product ->
            quantity = String.to_integer(cart_product_params["quantity"] || "0")

            price_when_carted = Decimal.mult(product.price, quantity)

            attrs = %{
              quantity: quantity,
              price_when_carted: price_when_carted,
              cart_id: cart_product,
              product_id: product.id
            }

            cart_product
            |> CartProduct.changeset(attrs)
            |> Repo.update()
        end
    end
  end

  def total_cart_product(cart_products) do
    Enum.reduce(cart_products, 0, fn item, acc ->
      item
      |> total_item_price()
      |> Decimal.add(acc)
    end)
  end

  def total_item_price(%CartProduct{} = item) do
    Decimal.mult(item.price_when_carted, item.quantity)
  end

  def prune_cart_items(cart_products) do
    [first_cart_products | _rest] = cart_products

    {_, _} =
      Repo.delete_all(
        from(i in CartProduct, where: i.user_uuid == ^first_cart_products.user_uuid)
      )

    {:ok}
  end

  def delete_cart_product(%CartProduct{} = cart_product) do
    Repo.delete(cart_product)
  end
end
