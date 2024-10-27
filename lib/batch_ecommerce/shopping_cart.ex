defmodule BatchEcommerce.ShoppingCart do
  @moduledoc """
  The ShoppingCart context.
  """

  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.ShoppingCart.Cart
  alias BatchEcommerce.ShoppingCart.CartItem
  alias BatchEcommerce.Accounts.User




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



  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end



  @doc """
  Returns the list of cart_items.

  ## Examples

      iex> list_cart_items()
      [%CartItem{}, ...]

  """
  def list_cart_items(conn) do
    return = get_cart_by_user_uuid(conn.private.guardian_default_resource.id)
     |> Map.get(:items)
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
        order_by: [asc: i.inserted_at],
        preload: [items: {i, product: p}]
      )
    )
  end

  def add_item_to_cart(%Cart{} = cart, cart_item_params) do

    case BatchEcommerce.Catalog.get_product(cart_item_params["product_id"]) do
      nil ->
        {:error, :not_found}

      product ->

        quantity = String.to_integer(cart_item_params["quantity"] || "0")

        price_when_carted = Decimal.mult(product.price, quantity)

        %CartItem{quantity: quantity, price_when_carted: price_when_carted, cart_id: cart.id, product_id: product.id}
        |> CartItem.changeset(%{})
        |> Repo.insert()
    end
  end
  
  def get_cart_item(id) do
    case Repo.get(CartItem, id) do
      nil ->
        {:error, :not_found}
      cart_item -> Repo.preload(cart_item, :product)
    end
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

    case BatchEcommerce.Catalog.get_product(cart_item_params["product_id"]) do
      nil ->
        {:error, :not_found}

      product ->
        quantity = String.to_integer(cart_item_params["quantity"] || "0")

        price_when_carted = Decimal.mult(product.price, quantity)

        attrs = %{quantity: quantity, price_when_carted: price_when_carted, cart_id: cart_item.cart_id, product_id: product.id}
        cart_item
        |> CartItem.changeset(attrs)
        |> Repo.update()
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart_item changes.

  ## Examples

      iex> change_cart_item(cart_item)
      %Ecto.Changeset{data: %CartItem{}}

  """
  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end
end
