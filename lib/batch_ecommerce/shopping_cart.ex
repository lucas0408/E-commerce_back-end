defmodule BatchEcommerce.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.ShoppingCart.Cart
  alias BatchEcommerce.ShoppingCart.CartItem

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """

  def total_item_price(%CartItem{} = item) do
    Decimal.mult(item.price_when_carted, item.quantity)
  end

  def total_cart_price(%Cart{} = cart) do
    Enum.reduce(cart.items, 0, fn item, acc ->
      item
      |> total_item_price()
      |> Decimal.add(acc)
    end)
  end

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Repo.insert()
  end

  def prune_cart_items(%Cart{} = cart) do
    {_, _} = Repo.delete_all(from(i in CartItem, where: i.cart_id == ^cart.id))
    {:ok, reload_cart(cart)}
  end

  defp reload_cart(%Cart{} = cart) do
    Repo.get!(Cart, cart.id)
    |> Repo.preload(:items)
  end

  @doc """
  Gets a single cart_item.

  Raises `Ecto.NoResultsError` if the Cart item does not exist.

  ## Examples

      iex> get_cart_item!(123)
      %CartItem{}

      iex> get_cart_item!(456)
      ** (Ecto.NoResultsError)

  """

  def get_cart_by_user_uuid(user_id) do
    Repo.one(
      from(c in Cart,
        where: c.user_id == ^user_id,
        left_join: i in assoc(c, :items),
        left_join: p in assoc(i, :product),
        left_join: ca in assoc(p, :categories),
        order_by: [asc: i.inserted_at],
        preload: [items: {i, product: {p, categories: ca}}]
      )
    )
  end

  def add_item_to_cart(%Cart{} = cart, cart_item_params) do
    product_id = Map.get(cart_item_params, "product_id")

    product = BatchEcommerce.Catalog.get_product(product_id)

    quantity = String.to_integer(cart_item_params["quantity"] || "0")

    price_when_carted = Decimal.mult(product.price, quantity)

    attrs = %{
      quantity: quantity,
      price_when_carted: price_when_carted,
      cart_id: cart.id,
      product_id: product.id
    }

    case create_cart_item(attrs) do
      {:ok, cart_item} ->
        {:ok, Repo.preload(cart_item, product: :categories)}

      error ->
        error
    end
  end

  def create_cart_item(attrs \\ %{}) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, cart_item} ->
        {:ok, Repo.preload(cart_item, product: [:categories])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_cart_item(id) do
    case Repo.get(CartItem, id) do
      nil ->
        {:error, :not_found}

      cart_item ->
        Repo.preload(cart_item, product: [:categories])
    end
  end

  def preload_product(item_cart) do
    Repo.preload(item_cart, :product)
  end

  @doc """
  Updates a cart_item.

  ## Examples

      iex> update_cart_item(cart_item, %{field: new_value})
      {:ok, %CartItem{}}

      iex> update_cart_item(cart_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart_item(%CartItem{} = cart_item, cart_item_params) do
    case cart_item_params["product_id"] do
      nil ->
        {:error, :not_found}

      product_id ->
        case BatchEcommerce.Catalog.get_product(product_id) do
          nil ->
            {:error, :not_found}

          product ->
            quantity = String.to_integer(cart_item_params["quantity"] || "0")

            price_when_carted = Decimal.mult(product.price, quantity)

            attrs = %{
              quantity: quantity,
              price_when_carted: price_when_carted,
              cart_id: cart_item.cart_id,
              product_id: product.id
            }

            cart_item
            |> CartItem.changeset(attrs)
            |> Repo.update()
        end
    end
  end

  @doc """
  Deletes a cart_item.

  ## Examples

      iex> delete_cart_item(cart_item)
      {:ok, %CartItem{}}

      iex> delete_cart_item(cart_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end
end
