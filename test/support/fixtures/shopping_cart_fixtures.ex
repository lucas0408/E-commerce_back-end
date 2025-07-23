defmodule BatchEcommerce.ShoppingCartFixtures do
<<<<<<< HEAD
  import BatchEcommerce.CatalogFixtures
  alias BatchEcommerce.ShoppingCart

=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BatchEcommerce.ShoppingCart` context.
  """

  @doc """
  Generate a unique cart user_uuid.
  """
  def unique_cart_user_uuid do
<<<<<<< HEAD
    UUID.uuid4()
=======
    raise "implement the logic to generate a unique cart user_uuid"
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
  end

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        user_uuid: unique_cart_user_uuid()
      })
      |> BatchEcommerce.ShoppingCart.create_cart()

    cart
  end

  @doc """
  Generate a cart_item.
  """
<<<<<<< HEAD
  def cart_item_fixture(attrs, conn) when not is_nil(conn) do
    cart_item_params =
      attrs
      |> Enum.into(%{
        "product_id" => product_fixture().id,
        "quantity" => "10"
      })

    {:ok, cart_item} =
      ShoppingCart.add_item_to_cart(
        ShoppingCart.get_cart_by_user_uuid(conn.private.guardian_default_resource.id),
        cart_item_params
      )

    cart_item
  end

  def cart_item_fixture(attrs \\ %{}) do
    cart_item_params =
      attrs
      |> Enum.into(%{
        "product_id" => product_fixture().id,
        "quantity" => "10"
      })

    {:ok, cart_item} =
      ShoppingCart.add_item_to_cart(
        ShoppingCart.get_cart_by_user_uuid(BatchEcommerce.AccountsFixtures.user_fixture().id),
        cart_item_params
      )
=======
  def cart_item_fixture(attrs \\ %{}) do
    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        price_when_carted: "120.5",
        quantity: 42
      })
      |> BatchEcommerce.ShoppingCart.create_cart_item()
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

    cart_item
  end
end
