defmodule BatchEcommerceWeb.CategoryController do
  use BatchEcommerceWeb, :controller

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Category

  action_fallback BatchEcommerceWeb.FallbackController

  def index(conn, _params) do
    case Catalog.list_categories() do
      [] ->
        {:error, :not_found}

      categories ->
        conn
        |> put_status(:ok)
        |> render(:index, category: categories)
    end
  end

  def create(conn, %{"category" => category_params}) do
    with {:ok, %Category{} = category} <- Catalog.create_category(category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/categories/#{category}")
      |> render(:show, category: category)
    end
  end

  def show(conn, %{"id" => id}) do
    case Catalog.get_category(id) do
      %Category{} = category ->
        conn
        |> put_status(:ok)
        |> render(:show, category: category)

      {:error, :not_found} ->
        {:error, :not_found}

      _unkown_error ->
        {:error, :internal_server_error}
    end
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    with %Category{} = category <- Catalog.get_category(id),
        {:ok, %Category{} = category}  <- Catalog.update_category(category, category_params) do
      conn
      |> put_status(:ok)
      |> render(:show, category: category)
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end
  end

  def delete(conn, %{"id" => id}) do
    with %Category{} = category <- Catalog.get_category(id),
        {:ok, %Category{}} <- Catalog.delete_category(category) do
      send_resp(conn, :no_content, "")
    else
      nil -> {:error, :not_found}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
      _unkown_error -> {:error, :internal_server_error}
    end
  end
end
