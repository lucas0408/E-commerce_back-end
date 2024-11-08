defmodule BatchEcommerceWeb.ProductJSON do
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog

  @doc """
  Renders a list of products.
  """
  def index(%{products: products}) do
    %{data: for(product <- products, do: data(product))}
  end

  @doc """
  Renders a single product.
  """
  def show(%{product: product}) do
    %{data: data(product)}
  end

  def data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      price: product.price,
      stock_quantity: product.stock_quantity,
      category: BatchEcommerceWeb.CategoryJSON.data(Catalog.preload_category(product).category)
    }
  end
end
