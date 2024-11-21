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
      {:ok, category} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/categories/#{category}")
        |> render(:show, category: category)

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_category(id) do
      %Category{} = category ->
        conn
        |> put_status(:ok)
        |> render(:show, category: category)

      nil ->
        {:error, :not_found}
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    with %Category{} = category_found <- Catalog.get_category(id),
         {:ok, category_updated} <-
           Catalog.update_category(category_found, category_params) do
      conn
      |> put_status(:ok)
      |> render(:show, category: category_updated)
    else
      nil ->
        {:error, :not_found}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Category{} = category_found <- Catalog.get_category(id),
         {:ok, _deleted_category} <- Catalog.delete_category(category_found) do
      send_resp(conn, :no_content, "")
    else
      nil ->
        {:error, :bad_request}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end
end
