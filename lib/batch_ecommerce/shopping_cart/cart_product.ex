defmodule BatchEcommerce.ShoppingCart.CartProduct do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_products" do
    field :price_when_carted, :decimal
    field :quantity, :integer
    belongs_to :user, BatchEcommerce.Accounts.User
    belongs_to :product, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_product, attrs) do
    cart_product
    |> cast(attrs, [:price_when_carted, :quantity, :product_id, :user_uuid])
    |> validate_required([:price_when_carted, :quantity])
    |> validate_number(:quantity, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
    |> unique_constraint(
      [:user_uuid, :product_id],
      message: "Product already exists in cart"
    )
    |> assoc_constraint(:user)
    |> assoc_constraint(:product)
  end
end
