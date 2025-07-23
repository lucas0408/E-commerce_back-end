defmodule BatchEcommerce.ShoppingCartTest do
<<<<<<< HEAD
  use BatchEcommerce.DataCase, async: true

  alias BatchEcommerce.ShoppingCart

  alias BatchEcommerce.Repo

=======
  use BatchEcommerce.DataCase

  alias BatchEcommerce.ShoppingCart

>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
  describe "carts" do
    alias BatchEcommerce.ShoppingCart.Cart

    import BatchEcommerce.ShoppingCartFixtures

<<<<<<< HEAD
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
=======
    @invalid_attrs %{user_uuid: nil}

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert ShoppingCart.list_carts() == [cart]
    end

    test "get_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert ShoppingCart.get_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart" do
      valid_attrs = %{user_uuid: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Cart{} = cart} = ShoppingCart.create_cart(valid_attrs)
      assert cart.user_uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart = cart_fixture()
      update_attrs = %{user_uuid: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Cart{} = cart} = ShoppingCart.update_cart(cart, update_attrs)
      assert cart.user_uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.update_cart(cart, @invalid_attrs)
      assert cart == ShoppingCart.get_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = ShoppingCart.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> ShoppingCart.get_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = ShoppingCart.change_cart(cart)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end
  end

  describe "cart_items" do
<<<<<<< HEAD
    import BatchEcommerce.AccountsFixtures

=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    alias BatchEcommerce.ShoppingCart.CartItem

    import BatchEcommerce.ShoppingCartFixtures

<<<<<<< HEAD
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
      cart_item = cart_item_fixture()
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
=======
    @invalid_attrs %{price_when_carted: nil, quantity: nil}

    test "list_cart_items/0 returns all cart_items" do
      cart_item = cart_item_fixture()
      assert ShoppingCart.list_cart_items() == [cart_item]
    end

    test "get_cart_item!/1 returns the cart_item with given id" do
      cart_item = cart_item_fixture()
      assert ShoppingCart.get_cart_item!(cart_item.id) == cart_item
    end

    test "create_cart_item/1 with valid data creates a cart_item" do
      valid_attrs = %{price_when_carted: "120.5", quantity: 42}

      assert {:ok, %CartItem{} = cart_item} = ShoppingCart.create_cart_item(valid_attrs)
      assert cart_item.price_when_carted == Decimal.new("120.5")
      assert cart_item.quantity == 42
    end

    test "create_cart_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart_item(@invalid_attrs)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "update_cart_item/2 with valid data updates the cart_item" do
      cart_item = cart_item_fixture()
<<<<<<< HEAD
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
=======
      update_attrs = %{price_when_carted: "456.7", quantity: 43}

      assert {:ok, %CartItem{} = cart_item} = ShoppingCart.update_cart_item(cart_item, update_attrs)
      assert cart_item.price_when_carted == Decimal.new("456.7")
      assert cart_item.quantity == 43
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "update_cart_item/2 with invalid data returns error changeset" do
      cart_item = cart_item_fixture()
<<<<<<< HEAD
      invalid_attrs = %{"product_id" => nil, "quantity" => "100"}

      assert {:error, :not_found} = ShoppingCart.update_cart_item(cart_item, invalid_attrs)
      assert ShoppingCart.get_cart_item(cart_item.id) != 100
=======
      assert {:error, %Ecto.Changeset{}} = ShoppingCart.update_cart_item(cart_item, @invalid_attrs)
      assert cart_item == ShoppingCart.get_cart_item!(cart_item.id)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "delete_cart_item/1 deletes the cart_item" do
      cart_item = cart_item_fixture()
      assert {:ok, %CartItem{}} = ShoppingCart.delete_cart_item(cart_item)
<<<<<<< HEAD
      assert ShoppingCart.get_cart_item(cart_item.id) == {:error, :not_found}
=======
      assert_raise Ecto.NoResultsError, fn -> ShoppingCart.get_cart_item!(cart_item.id) end
    end

    test "change_cart_item/1 returns a cart_item changeset" do
      cart_item = cart_item_fixture()
      assert %Ecto.Changeset{} = ShoppingCart.change_cart_item(cart_item)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end
  end
end
