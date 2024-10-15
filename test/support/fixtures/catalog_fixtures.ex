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
        type: "some type"
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
        price: "120.5",
        stock_quantity: 42
      })
      |> BatchEcommerce.Catalog.create_product()

    product
  end
end
