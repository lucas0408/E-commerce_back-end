defmodule BatchEcommerce.Orders.OrderProducts do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_products" do
    field :price, :decimal
    field :quantity, :integer

    belongs_to :order, BatchEcommerce.Orders.Order
    belongs_to :product, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order_product, attrs) do
    order_product
    |> cast(attrs, [:price, :quantity])
    |> validate_required([:price, :quantity])
  end
end
