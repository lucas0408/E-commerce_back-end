defmodule BatchEcommerce.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :decimal
      add :stock_quantity, :integer
      add :image_url, :string
      add :description, :string
      add :company_uuid,references(:companies, on_delete: :delete_all)
      add :category_id, references(:categories)

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:category_id])
  end
end
