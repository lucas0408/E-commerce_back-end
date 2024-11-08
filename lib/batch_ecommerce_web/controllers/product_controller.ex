defmodule BatchEcommerceWeb.ProductController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Repo
  alias BatchEcommerce.Catalog.Product

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    case Catalog.list_products() do
      [] ->
        {:error, :not_found}

      products ->
        conn
        |> put_status(:ok)
        |> render(:index, products: products)
    end
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
    with %Product{} = product <- Catalog.get_product(id) do
      conn
      |> put_status(:ok)
      |> render(:show, product: product)
    else
      nil ->
        {:error, :not_found}

      _unkown_error ->
        {:error, :internal_server_error}
    end

  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    with %Product{} = product <- Catalog.get_product(id),
         {:ok, %Product{} = product} <- Catalog.update_product(product, product_params) do
      conn
      |> put_status(:ok)
      |> render(:show, product: product)
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Product{} = product <- Catalog.get_product(id),
        {:ok, %Product{}} <- Catalog.delete_product(product) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      _unkown_error -> {:error, :internal_server_error}
    end
  end
end
