defmodule BatchEcommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :decimal
      add :stock_quantity, :integer
      add :category_id, references(:categories)

      timestamps(type: :utc_datetime)
    encode_and_sign
    create unique_index(:products, [:name])
    create index(:products, [:category_id])
  end
end
