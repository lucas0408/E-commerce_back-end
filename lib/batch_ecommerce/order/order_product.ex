defmodule BatchEcommerce.Order.OrderProduct do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_products" do
    field :price, :decimal
    field :quantity, :integer

    belongs_to :order, BatchEcommerce.Order.Order
    belongs_to :product, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order_product, attrs) do
    order_product
    |> cast(attrs, [:price, :quantity, :product_id, :order_id])
    |> validate_required([:price, :quantity, :product_id, :order_id])
    |> assoc_constraint(:order)
  end
end
