defmodule BatchEcommerce.Catalog.ProductsCategories do
  use Ecto.Schema

  @derive {
    Flop.Schema,
    filterable: [:category_type],
    sortable: [:category_type],
    adapter_opts: [
      join_fields: [
        category_type: [
          binding: :categories,
          field: :type,
          path: [:categories, :type]
        ]
      ]
    ]
  }

  @primary_key false
  schema "products_categories" do
    belongs_to :product, BatchEcommerce.Catalog.Product
    belongs_to :category, BatchEcommerce.Catalog.Category
    timestamps()
  end
end
