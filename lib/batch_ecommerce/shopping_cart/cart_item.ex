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
    |> validate_number(:quantity, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> unique_constraint(
      [:cart_id, :product_id],
      message: "Product already exists in cart"
    )
    |> assoc_constraint(:cart)
    |> assoc_constraint(:product)
  end
end
