defmodule BatchEcommerce.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :total_price, :decimal, precision: 15, scale: 6, null: false
      add :status_payment, :string

      timestamps(type: :utc_datetime)
    end
  end
end
