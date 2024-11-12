defmodule BatchEcommerceWeb.ProductController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog
  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    products = Catalog.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    with {:ok, %Product{} = product} <- Catalog.create_product(product_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/products/#{product}")
      |> render(:show, product: product)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Catalog.get_product(id)

    render(conn, :show, product: product)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with {:ok, %Product{} = product_found} <- Catalog.get_product(id),
         {:ok, %Product{} = product_updated} <-
           Catalog.update_product(product_found, product_params) do
      render(conn, :show, product: product_updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Product{} = product_found} <- Catalog.get_product(id),
         {:ok, %Product{}} <-
           Catalog.delete_product(product_found) do
      send_resp(conn, :no_content, "")
    end
  end
end
