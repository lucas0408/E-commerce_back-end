defmodule BatchEcommerce.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.ShoppingCart.CartProduct

  def list_cart_products, do: Repo.all(CartProduct) |> preload_product()

  def get_cart_user(user_id) do
    query = from(i in CartProduct, where: i.user_id == ^user_id)
    Repo.all(query)
    |> preload_product()
  end

  def create_cart_prodcut(user_id, cart_item_params) do
    case Map.get(cart_item_params, "product_id") do
      nil ->
        {:error, :not_found}   

      product_id ->

        product = BatchEcommerce.Catalog.get_product(product_id)

        quantity = cart_item_params["quantity"] || "0"

        discount_multiplier = Decimal.div(Decimal.sub(100, product.discount), 100)
        price_when_carted =
          product.price
          |> Decimal.mult(quantity)
          |> Decimal.mult(discount_multiplier)

        attrs = %{
          quantity: quantity,
          price_when_carted: price_when_carted,
          user_id: user_id,
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
  end

  def get_cart_product(id) do
    Repo.get(CartProduct, id)
  end

  def preload_product(cart_product) do
    Repo.preload(cart_product, product: [:categories, :company])
  end

  def total_cart_products_quantity(product_id) do
    from(cp in CartProduct, where: cp.product_id == ^product_id, select: sum(cp.quantity))
    |> Repo.one()
    |> case do
      nil -> 0
      total -> total
    end
  end

  def update_cart_product(%CartProduct{} = cart_product, cart_product_params) do
    
    product = preload_product(cart_product).product

    quantity = cart_product_params["quantity"] || "0"

    price_when_carted = Decimal.mult(product.price, quantity)

    attrs = %{
      quantity: quantity,
      price_when_carted: price_when_carted,
      user_id: cart_product.user_id,
      product_id: product.id
    }

    cart_product
    |> CartProduct.changeset(attrs)
    |> Repo.update()
    |> case do
        {:ok, cart_product} ->
          {:ok, preload_product(cart_product)}

        {:error, changeset} ->
          {:error, changeset}
      end
  end

  def total_price_cart_product(cart_products) do
    cart_products = cart_products
    |> preload_product()
    total_price = Enum.reduce(cart_products, Decimal.new("0"), fn cart_product, acc ->
      price = Decimal.new(cart_product.price_when_carted)
      discount = cart_product.product.discount || 0
      discounted_price = calculate_discounted_price(price, discount)
      Decimal.add(acc, discounted_price)
    end)
    |> Decimal.round(2)
    total_price
  end

  
  defp calculate_discounted_price(price, discount) do
    discount_decimal = Decimal.new(discount)
    hundred = Decimal.new(100)
    discount_factor = Decimal.sub(hundred, discount_decimal) |> Decimal.div(hundred)
    discount_price = Decimal.mult(price, discount_factor)
    discount_price
  end


  def prune_cart_items(user_id) do
    {_, _} =
      Repo.delete_all(
        from(i in CartProduct, where: i.user_id == ^user_id)
      )

    {:ok, "any"}
  end

  def delete_cart_product(%CartProduct{} = cart_product) do
    Repo.delete(cart_product)
  end
end
