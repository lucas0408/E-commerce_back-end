defmodule BatchEcommerce.Repo.Migrations.CreateProductReviews do
  use Ecto.Migration

  def change do
    create table(:product_reviews) do
      add :review, :integer, null: false, comment: "Rating from 1 to 5"
      add :product_id, references(:products, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :uuid), null: false

      timestamps()
    end

    create index(:product_reviews, [:product_id])
    create index(:product_reviews, [:user_id])
    create index(:product_reviews, [:product_id, :user_id])
    
    create unique_index(:product_reviews, [:product_id, :user_id], 
           name: :product_reviews_product_user_unique_index)

    create constraint(:product_reviews, :review_range, check: "review >= 1 AND review <= 5")
  end
end