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
        assert cart_product.user_id = get_cart_product.user_id
        assert cart_product.product_id == get_cart_product.product_id
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
