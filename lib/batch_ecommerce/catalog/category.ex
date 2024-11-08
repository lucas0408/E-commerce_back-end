defmodule BatchEcommerce.Catalog.Category do
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
  end

  defp validate_type(changeset),
    do:
      changeset
      |> validate_length(:type, min: 2, max: 40, message: "Insira um tipo de categoria válido")
end
