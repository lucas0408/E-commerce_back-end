defmodule BatchEcommerce.Catalog.Category do :products, Product, join_through: "products_categories", on_replace: :delete
=======
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :type, :string
    has_many :products, BatchEcommerce.Catalog.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> unique_constraint(:type)
    |> validate_type()
    |> validate_uniqueness_of_fields([:type])
  end

  defp validate_type(changeset),
    do: changeset |> validate_length(:type, min: 2, max: 40, message: "enter a valid type")

  defp validate_uniqueness_of_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc_changeset ->
      changes = get_change(acc_changeset, field)

      if changes && BatchEcommerce.Catalog.category_exists_with_field?(field, changes) do
        add_error(acc_changeset, field, "Já esta em uso")
      else
        acc_changeset
      end
    end)
  end
end
