defmodule BatchEcommerce.Order.OrderProduct do
  use Ecto.Schema
  import Ecto.Changeset

   @derive {Jason.Encoder, only: [:id, :price, :quantity, :product_id, :order_id, :inserted_at, :updated_at, :product]}

  schema "order_products" do
    field :price, :decimal
    field :quantity, :integer
    field :status, :string

    belongs_to :order, BatchEcommerce.Order.Order
    belongs_to :product, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)

    
  end

  @doc false
  def changeset(order_product, attrs) do
    order_product
    |> cast(attrs, [:price, :quantity, :product_id, :order_id, :status])
    |> validate_required([:price, :quantity, :product_id, :order_id])
    |> assoc_constraint(:order)
  end
end
