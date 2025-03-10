defmodule BatchEcommerce.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do

      add :total_price, :decimal, precision: 15, scale: 6, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
