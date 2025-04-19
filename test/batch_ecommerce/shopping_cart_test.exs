defmodule BatchEcommerce.ShoppingCartTest do
    use BatchEcommerce.DataCase, async: true

    alias BatchEcommerce.ShoppingCart

    import BatchEcommerce.Factory

    alias BatchEcommerce.Repo

    describe "cart_products" do
        alias BatchEcommerce.ShoppingCart.CartProduct


    test "prune_cart_items/1 delete all cart_items from cart" do
        list_cart_itens = insert_list(5, :cart_product)

        IO.inspect(Enum.at(list_cart_itens, 0).user_id)

        user_id = Enum.at(list_cart_itens, 0).user_id

        assert list_cart_itens == ShoppingCart.get_cart_user(user_id)

        ShoppingCart.prune_cart_items(list_cart_itens)

        assert ShoppingCart.get_cart_user(user_id) == nil
    end

    test "get_cart_user/1 get user cart" do
        user = insert(:user)

        cart_product_list = Enum.map(1..3, fn _ -> params_for(:cart_product) end)

        list_with_user_id =
        Enum.map(cart_product_list, fn params ->
            ShoppingCart.create_cart_prodcut(user.id, atom_keys_to_string(%{params | user_id: user.id}))
        end)

        generic_cart_products = insert_list(3, :cart_product)

        list_with_user_id == ShoppingCart.get_cart_user(user.id)

        list_with_user_id != generic_cart_products
        
    end

    test "create_cart_product/2 with a valid data create a cart_product" do
        valid_attrs = params_for(:cart_product)

        cart_attrs = atom_keys_to_string(valid_attrs)

        assert {:ok, %CartProduct{} = cart_product} = ShoppingCart.create_cart_prodcut(valid_attrs.user_id, cart_attrs)

        IO.inspect(cart_product.price_when_carted)

        assert cart_product.price_when_carted == Decimal.new("123.0")

        assert cart_product.quantity == valid_attrs.quantity

        assert cart_product.user_id == valid_attrs.user_id

        assert cart_product.product_id == valid_attrs.product_id
    end

    test "create_cart_product/2 with a invalid dat create a cart_product" do
        attrs = params_for(:cart_product)

        invalid_attrs = %{attrs | quantity: -1}

        invalid_cart_attrs = atom_keys_to_string(invalid_attrs)

        assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart_prodcut(invalid_attrs.user_id, invalid_cart_attrs)

        invalid_attrs = invalid_params_for(:cart_product, [:user_id])

        invalid_cart_attrs = atom_keys_to_string(invalid_attrs)

        assert {:error, %Ecto.Changeset{}} = ShoppingCart.create_cart_prodcut(invalid_attrs.user_id, invalid_cart_attrs)
    end

    test "get_cart_product/1 get cart by id" do

        cart_product = insert(:cart_product)

        get_cart_product = ShoppingCart.get_cart_product(cart_product.id)

        assert cart_product.id == get_cart_product.id
        assert cart_product.price_when_carted == get_cart_product.price_when_carted
        assert cart_product.quantity == get_cart_product.quantity
        assert cart_product.user_id == get_cart_product.user_id
        assert cart_product.product_id == get_cart_product.product_id
    end

    test "preload_product/1 loads product and categories data" do
        cart_product = insert(:cart_product)

        preload_cart_product = ShoppingCart.preload_product(cart_product)

        assert %Ecto.Association.NotLoaded{} = cart_product.product

        assert %BatchEcommerce.Catalog.Product{} = preload_cart_product.product

        assert [%BatchEcommerce.Catalog.Category{}] = preload_cart_product.product.categories
    end

    test "update_cart_product/2 with valid data updates the cart_product" do
        update_attrs = atom_keys_to_string(params_for(:cart_product))

        cart_product = insert(:cart_product)

        assert {:ok, %ShoppingCart.CartProduct{} = update_cart_product} = ShoppingCart.update_cart_product(cart_product, update_attrs)

        assert update_cart_product.user_id == cart_product.user_id #need be equal 
        assert update_cart_product.product_id != cart_product.product_id #product is updated
    end

    test "update_cart_product/2 with invalid data updates the cart_product" do
        invalid_update_attrs = atom_keys_to_string(invalid_params_for(:cart_product, [:product_id]))

        cart_product = insert(:cart_product)

        assert {:error, :not_found} = ShoppingCart.update_cart_product(cart_product, invalid_update_attrs)

        invalid_attrs = %{params_for(:cart_product) | quantity: -1}

        invalid_cart_attrs = atom_keys_to_string(invalid_attrs)

        assert {:error, %Ecto.Changeset{}} = ShoppingCart.update_cart_product(cart_product, invalid_cart_attrs)
    end

    test "total_price_cart_product/1 calculates total cart price" do
        list_cart_product = insert_list(5, :cart_product)

        total_price_function = ShoppingCart.total_price_cart_product(list_cart_product)

        total_price_enum = Enum.reduce(list_cart_product, Decimal.new(0), fn cart_product, acc -> 
            Decimal.add(acc, cart_product.price_when_carted)
        end)

        IO.inspect(total_price_enum)

        assert total_price_function == total_price_enum
    end

    test "delete_cart_product/1 deletes the cart_product" do
        cart_product = insert(:cart_product)

        assert %CartProduct{} = ShoppingCart.get_cart_product(cart_product.id)

        ShoppingCart.delete_cart_product(cart_product)

        assert ShoppingCart.get_cart_product(cart_product.id) == {:error, :not_found}
    end

    def atom_keys_to_string(map) when is_map(map) do
        Map.new(map, fn
        {k, v} when is_atom(k) and is_map(v) -> {Atom.to_string(k), atom_keys_to_string(v)}
        {k, v} when is_atom(k) -> {Atom.to_string(k), v}
        {k, v} -> {k, v}
        end)
    end
   end
end
