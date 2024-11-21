defmodule BatchEcommerce.Catalog.Category do
  @moduledoc """
  The category schema module.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias BatchEcommerce.Catalog.Product

  schema "categories" do
    field :type, :string
    many_to_many :products, Product, join_through: "product_categories", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:type])
    |> validate_required([:type])
    |> unique_constraint(:type)
    |> validate_type()
  end

  defp validate_type(changeset),
    do:
      changeset
      |> validate_length(:type, min: 2, max: 40, message: "Insira um tipo de categoria válido")
end
