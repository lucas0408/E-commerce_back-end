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
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock_quantity, :category_id])
    |> validate_required([:name, :price, :stock_quantity])
    |> unique_constraint(:name)
    |> validate_name()
    |> valiate_price()
    |> valiate_stock_quantity()
    |> assoc_constraint(:category)
    |> validate_uniqueness_of_fields([:name])
  end

  defp validate_name(changeset),
    do: changeset |> validate_length(:name, min: 2, max: 60, menssage: "enter a valid product name")

  defp valiate_price(changeset),
    do: changeset |> validate_number(:price, greater_than: 0)

  defp valiate_stock_quantity(changeset),
    do: changeset |> validate_number(:stock_quantity, greater_than: 0)


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
