defmodule BatchEcommerce.Repo.Migrations.CreateProductCategories do
  use Ecto.Migration

  def change do
    create table(:products_categories, primary_key: false) do
      add :product_id, references(:products, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create index(:products_categories, [:product_id])
    create unique_index(:products_categories, [:category_id, :product_id])
  end
end
