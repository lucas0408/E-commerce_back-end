defmodule BatchEcommerce.ShoppingCart.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    field :price_when_carted, :decimal
    field :quantity, :integer

    belongs_to :cart, BatchEcommerce.ShoppingCart.Cart
    belongs_to :product, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:price_when_carted, :quantity, :product_id, :cart_id])
    |> validate_required([:price_when_carted, :quantity])
    |> check_quantity
    |> unique_constraint(
      [:cart_id, :product_id],
      message: "Product already exists in cart"
    )
    |> assoc_constraint(:cart)
    |> assoc_constraint(:product)
  end

  defp check_quantity(changeset) do
    case get_field(changeset, :quantity) do
      nil -> changeset
      quantity when quantity <= 0 ->
        add_error(changeset, :quantity, "the quantity has to be greater than 0 or less then 100")
      _ -> changeset
    end
  end
end
