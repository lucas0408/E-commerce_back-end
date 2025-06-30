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
    |> validate_inclusion(:review, 1..5, message: "A avaliação deve ser entre 1 e 5 estrelas")
    |> unique_constraint([:user_id, :product_id], 
        name: :product_reviews_user_id_product_id_index,
        message: "Você já avaliou este produto")
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:user_id)
  end
end