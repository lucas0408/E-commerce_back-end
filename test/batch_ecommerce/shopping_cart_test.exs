defmodule BatchEcommerce.ShoppingCartTest do
  use BatchEcommerce.DataCase, async: true

  alias BatchEcommerce.ShoppingCart

  alias BatchEcommerce.Repo

  describe "carts" do
    alias BatchEcommerce.ShoppingCart.Cart

    import BatchEcommerce.ShoppingCartFixtures

    import BatchEcommerce.AccountsFixtures

    # @invalid_attrs %{user_uuid: nil}

    test "get_cart_by_user_uuid!/1 returns the cart with given user_id" do
      user_id = user_fixture().id
      assert %Cart{} = ShoppingCart.get_cart_by_user_uuid(user_id)
    end

    test "create_cart/1 with valid data creates a cart" do
      user = user_fixture()
      assert %Cart{} = ShoppingCart.get_cart_by_user_uuid(user.id)
    end

    test "prune_cart_items/1 delete all cart_items from cart" do
      cart_item = cart_item_fixture()

      cart = Repo.preload(cart_item, cart: :items).cart

      {:ok, cart_items_empty} = ShoppingCart.prune_cart_items(cart)

      assert cart.items == [cart_item]
      assert cart_items_empty.items == []
    end
  end

  describe "cart_items" do
    import BatchEcommerce.AccountsFixtures

    alias BatchEcommerce.ShoppingCart.CartItem

    import BatchEcommerce.ShoppingCartFixtures

    import BatchEcommerce.CatalogFixtures

    alias BatchEcommerce.Catalog.Product

    @invalid_attrs %{price_when_carted: nil, quantity: nil}

    test "total_item_price/1 returns total item price" do
      cart_item = cart_item_fixture()

      assert ShoppingCart.total_item_price(ShoppingCart.preload_product(cart_item)) ==
               Decimal.mult(cart_item.price_when_carted, cart_item.quantity)
    end

    test "total_cart_price/0 returns total cart price" do
      cart_item = ShoppingCart.preload_product(cart_item_fixture())

      assert ShoppingCart.total_cart_price(Repo.preload(cart_item, cart: [items: :product]).cart) ==
               Decimal.mult(cart_item.price_when_carted, cart_item.quantity)
    end

    test "get_cart_item/1 returns the cart_item with given id" do
      cart_item = ShoppingCart.preload_product(cart_item_fixture())
      assert ShoppingCart.get_cart_item(cart_item.id) == cart_item
    end

    test "add_item_to_cart/2 with valid data creates a cart_item" do
      valid_attrs = %{"product_id" => product_fixture().id, "quantity" => "10"}

      assert {:ok, %CartItem{} = cart_item} =
               ShoppingCart.add_item_to_cart(
                 ShoppingCart.get_cart_by_user_uuid(user_fixture().id),
                 valid_attrs
               )

      assert cart_item.price_when_carted == Decimal.mult("120.50", "10")
      assert cart_item.quantity == 10
    end

    test "create_cart_item/1 with invalid data returns error changeset" do
      invalid_attrs = %{"product_id" => product_fixture().id, "quantity" => "-1"}

      assert {:error, %Ecto.Changeset{}} =
               ShoppingCart.add_item_to_cart(
                 ShoppingCart.get_cart_by_user_uuid(user_fixture().id),
                 invalid_attrs
               )
    end

    test "update_cart_item/2 with valid data updates the cart_item" do
      cart_item = cart_item_fixture()
      update_attrs = %{"product_id" => cart_item.product_id, "quantity" => "100"}

      assert {:ok, %CartItem{} = cart_item} =
               ShoppingCart.update_cart_item(cart_item, update_attrs)

      assert cart_item.price_when_carted == Decimal.mult("120.50", "100")
      assert cart_item.quantity == 100
    end

    test "preload_product/1 return item_cart with products" do
      cart_item = cart_item_fixture()

      assert cart_item.product != %Product{}

      cart_item_preload = ShoppingCart.preload_product(cart_item)

      assert cart_item_preload.product.price == Decimal.new("120.50")
    end

    test "update_cart_item/2 with invalid data returns error changeset" do
      cart_item = cart_item_fixture()
      invalid_attrs = %{"product_id" => nil, "quantity" => "100"}

      assert {:error, :not_found} = ShoppingCart.update_cart_item(cart_item, invalid_attrs)
      assert ShoppingCart.get_cart_item(cart_item.id) != 100
    end

    test "delete_cart_item/1 deletes the cart_item" do
      cart_item = cart_item_fixture()
      assert {:ok, %CartItem{}} = ShoppingCart.delete_cart_item(cart_item)
      assert ShoppingCart.get_cart_item(cart_item.id) == {:error, :not_found}
    end
  end
end
