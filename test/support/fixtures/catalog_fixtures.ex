defmodule BatchEcommerce.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BatchEcommerce.Catalog` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
<<<<<<< HEAD
        type: "eletronicos"
=======
        type: "some type"
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
      })
      |> BatchEcommerce.Catalog.create_category()

    category
  end

  @doc """
  Generate a unique product name.
  """
  def unique_product_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: unique_product_name(),
<<<<<<< HEAD
        price: "120.50",
        stock_quantity: 42,
        description: "some description"
=======
        price: "120.5",
        stock_quantity: 42
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
      })
      |> BatchEcommerce.Catalog.create_product()

    product
  end
<<<<<<< HEAD

  def product_fixture_assoc(attrs_prod \\ %{}, attrs_cat \\ %{}) do
    category = category_fixture(attrs_cat)
    category_2 = category_fixture(type: "construção")
    category_3 = category_fixture(type: "banho")

    product_fixture(
      Map.put(attrs_prod, :category_ids, [category.id, category_2.id, category_3.id])
    )
    |> BatchEcommerce.Repo.preload(:categories)
  end
=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
end
