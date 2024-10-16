defmodule BatchEcommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :stock_quantity, :integer
    belongs_to :category, BatchEcommerce.Catalog.Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def insert_changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock_quantity, :category_id])
    |> validate_required([:name, :price, :stock_quantity])
    |> unique_constraint(:name)
    |> assoc_constraint(:category)
    |> validate_uniqueness_of_fields([:name])
  end

  def update_changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock_quantity, :category_id])
    |> validate_required([:name, :price, :stock_quantity])
    |> unique_constraint(:name)
    |> assoc_constraint(:category)
  end

  defp validate_uniqueness_of_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      changes = get_change(acc_changeset, field)

      if changes && BatchEcommerce.Catalog.product_exists_with_field?(field, changes) do
        add_error(acc_changeset, field, "Já esta em uso")
      else
        acc_changeset
      end
    end)
  end
end
