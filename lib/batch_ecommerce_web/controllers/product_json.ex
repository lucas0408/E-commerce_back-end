defmodule BatchEcommerceWeb.ProductJSON do
  alias BatchEcommerce.Catalog.Product

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

  defp data(%Product{} = product) do
    %{
      id: product.id,
      name: product.name,
      price: product.price,
      stock_quantity: product.stock_quantity,
      image_url: product.image_url,
      description: product.description,
      company_id: product.company_id,
      categories: BatchEcommerceWeb.CategoryJSON.index(%{categories: product.categories})
    }
  end
end
