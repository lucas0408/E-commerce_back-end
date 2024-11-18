defmodule BatchEcommerceWeb.ProductController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    products = Catalog.list_products()
    render(conn, :index, products: products)
  end

  def create(conn, %{"product" => product_params}) do
    case Catalog.create_product(product_params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/products/#{product}")
        |> render(:show, product: product)

      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _unknown_error ->
        {:error, :internal_server_error}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_product(id) do
      {:ok, product} ->
        conn
        |> put_status(:ok)
        |> render(:show, product: product)

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with {:ok, %Product{} = product_found} <- Catalog.get_product(id),
         {:ok, %Product{} = product_updated} <-
           Catalog.update_product(product_found, product_params) do
      render(conn, :show, product: product_updated)
    else
      nil -> {:error, :bad_request}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unknown_error -> {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Product{} = product_found} <- Catalog.get_product(id),
         {:ok, %Product{}} <-
           Catalog.delete_product(product_found) do
      send_resp(conn, :no_content, "")
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unknown_error -> {:error, :internal_server_error}
    end
  end
end
