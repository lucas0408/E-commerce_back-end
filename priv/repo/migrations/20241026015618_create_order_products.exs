defmodule BatchEcommerce.Repo.Migrations.CreateOrderProducts do
  use Ecto.Migration

  def change do
    create table(:order_products) do
      add :price, :decimal, precision: 15, scale: 6, null: false
      add :quantity, :integer
      add :order_id, references(:orders, on_delete: :delete_all)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:order_products, [:order_id])
    create index(:order_products, [:product_id])
  end
end
