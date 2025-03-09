defmodule BatchEcommerce.Repo.Migrations.CreateCartProducts do
  use Ecto.Migration

  def change do
    create table(:cart_products) do
      add :price_when_carted, :decimal, precision: 15, scale: 2, null: false
      add :quantity, :integer
      add :user_uuid, references(:users, on_delete: :delete_all)
      add :product_id, references(:products, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:cart_products, [:product_id])
    create unique_index(:cart_products, [:user_uuid, :product_id])
  end
end
