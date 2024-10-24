defmodule BatchEcommerce.ShoppingCart.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do

    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id  

    has_many :items, BatchEcommerce.ShoppingCart.CartItem

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
