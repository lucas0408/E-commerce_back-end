defmodule BatchEcommerceWeb.CategoryController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Category

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    categories = Catalog.list_categories()

    conn
    |> put_status(:ok)
    |> render(:index, categories: categories)
  end

  def create(conn, %{"category" => category_params}) do
    case Catalog.create_category(category_params) do
      {:ok, %Category{} = category} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/categories/#{category}")
        |> render(:show, category: category)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _unknown_error ->
        {:error, :internal_server_error}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_category(id) do
      {:ok, %Category{} = category} ->
        conn
        |> put_status(:ok)
        |> render(:show, category: category)

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    with {:ok, %Category{} = category_found} <- Catalog.get_category(id),
         {:ok, %Category{} = category_updated} <-
           Catalog.update_category(category_found, category_params) do
      conn
      |> put_status(:ok)
      |> render(:show, category: category_updated)
    else
      {:error, :not_found} ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _unknown_error ->
        {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Category{} = category_found} <- Catalog.get_category(id),
         {:ok, %Category{}} <- Catalog.delete_category(category_found) do
      send_resp(conn, :no_content, "")
    else
      {:error, :not_found} ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      _unknown_error ->
        {:error, :internal_server_error}
    end
  end
end
