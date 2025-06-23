defmodule BatchEcommerce.Catalog.ProductReview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "product_reviews" do
    field :review, :integer
    belongs_to :product, BatchEcommerce.Catalog.Product
    belongs_to :user, BatchEcommerce.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(product_review, attrs) do
    product_review
    |> cast(attrs, [:review, :product_id, :user_id])
    |> validate_required([:review, :product_id, :user_id])
    |> unique_constraint([:product_id, :user_id], 
         message: "você já avaliou este produto")
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:user_id)
  end
end