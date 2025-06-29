defmodule BatchEcommerceWeb.ProductController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    products = Catalog.list_products()

    conn
    |> put_status(:ok)
    |> render(:index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        #|> put_resp_header("location", ~p"/api/products/#{product}")
        |> render(:show, product: product)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_product(id) do
      %Product{} = product ->
        conn
        |> put_status(:ok)
        |> render(:show, product: product)

      nil ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with %Product{} = product_found <- Catalog.get_product(id),
         {:ok, product_updated} <-
           Catalog.update_product(product_found, product_params) do
      render(conn, :show, product: product_updated)
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Product{} = product_found <- Catalog.get_product(id),
         {:ok, _deleted_product} <-
           Catalog.delete_product(product_found) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end
end
