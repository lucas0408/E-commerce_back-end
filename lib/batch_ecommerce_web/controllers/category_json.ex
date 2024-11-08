defmodule BatchEcommerceWeb.CategoryJSON do
  alias BatchEcommerce.Catalog.Category

  @doc """
  Renders a list of products.
  """
  def index(%{categories: categories}) do
    %{data: for(category <- categories, do: data(category))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{category: category}) do
    %{data: data(category)}
  end

  def data(%Category{} = category) do
    %{
      id: category.id,
      type: category.type
    }
  end
end
