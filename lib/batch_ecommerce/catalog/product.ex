defmodule BatchEcommerce.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias BatchEcommerce.Catalog.Category

  @required_fields [:name, :price, :stock_quantity, :image_url]

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :stock_quantity, :integer
    field :image_url, :string
    many_to_many :categories, Category, join_through: "product_categories", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
    |> validate_name()
    |> validate_price()
    |> validate_stock_quantity()
    |> put_product_categories(attrs)
  end

  defp put_product_categories(changeset, %{categories: categories}) when is_list(categories) do
    put_assoc(changeset, :categories, categories)
  end

  defp put_product_categories(changeset, _), do: changeset

  defp validate_name(changeset),
    do: validate_length(changeset, :name, min: 2, max: 60, menssage: "enter a valid product name")

  defp validate_price(changeset),
    do: validate_number(changeset, :price, greater_than: 0)

  defp validate_stock_quantity(changeset),
    do: validate_number(changeset, :stock_quantity, greater_than: 0)
end
