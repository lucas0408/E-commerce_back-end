defmodule BatchEcommerce.Order.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :total_price, :decimal

    field :status_payment, :string

    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id

    has_many :order_products, BatchEcommerce.Order.OrderProduct

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :total_price, :status_payment])
    |> validate_required([:user_id, :total_price])
  end
end
