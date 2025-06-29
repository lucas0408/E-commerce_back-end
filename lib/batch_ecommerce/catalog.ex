defmodule BatchEcommerce.Catalog do
  @moduledoc """
  The Catalog context.
  """
  import Ecto.Query, warn: false
  alias BatchEcommerce.Repo

  alias BatchEcommerce.Catalog.Category
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog.ProductReview

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category(id) do
    Repo.get(Category, id)
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias BatchEcommerce.Catalog.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products() do
    Repo.all(Product)
    |> Repo.preload(:categories)
  end

  def list_products_by_all_category_ids(category_ids) do
    category_ids = 
      category_ids
      |> Enum.map(fn id ->
        if is_binary(id), do: String.to_integer(id), else: id
      end)

    query =
      from p in Product,
        join: pc in "products_categories", on: pc.product_id == p.id,
        where: pc.category_id in ^category_ids,
        group_by: p.id,
        having: count(pc.category_id) == ^length(category_ids),
        distinct: p.id

    Repo.all(query)
  end

def list_products_paginated(params) do
  # Começa com a query base filtrando apenas produtos ativos
  base_query = from p in Product, where: p.active == true

  # Aplica filtro de pesquisa se houver termo
  base_query = 
    if params[:search_query] && params.search_query != "" do
      search_term = "%#{params.search_query}%"
      from p in base_query, where: (ilike(p.name, ^search_term))
    else
      base_query
    end

  # Aplica filtro de categorias se houver seleção
  final_query =
    if params[:category_ids] && !Enum.empty?(params.category_ids) do
      subquery = 
        from p in base_query,
          join: pc in "products_categories", on: pc.product_id == p.id,
          where: pc.category_id in ^params.category_ids,
          group_by: p.id,
          having: count(pc.category_id) == ^length(params.category_ids),
          select: p.id

      from p in Product,
        where: p.id in subquery(subquery) ,
        order_by: [desc: p.inserted_at]
    else
      from p in base_query,
        order_by: [desc: p.inserted_at]
    end

  # Paginação
  final_query
  |> Repo.paginate(page: params.page, page_size: params.per_page)
end


  def list_company_products_paginated(company_id, search_term \\ "", page \\ 1, per_page \\ 6) do
    Product
    |> where([p], p.company_id == ^company_id)
    |> apply_search_filter(search_term)
    |> preload([:categories])  # Carrega as categorias associadas
    |> order_by([p], desc: p.inserted_at)
    |> Repo.paginate(page: page, page_size: per_page)
  end

  defp apply_search_filter(query, ""), do: query

  defp apply_search_filter(query, search_term) do
    search_term = "#{search_term}%"
    where(query, [p], ilike(p.name, ^search_term))
  end

  #@spec get_product(any()) :: nil | [%{optional(atom()) => any()}] | %{optional(atom()) => any()}
  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product(id) do
    Repo.get(Product, id)
    |> Repo.preload(:categories)
  end

  def get_top_selling_products(company_id, limit \\ 5) do
    Product
    |> where([p], p.company_id == ^company_id)
    |> order_by([p], desc: p.sales_quantity)
    |> limit(^limit)
    |> Repo.all()
  end

  def return_stock(return_quantity, product_id) when return_quantity > 0 do
    product = get_product(product_id)

    IO.inspect(product.stock_quantity)
    
    new_stock = product.stock_quantity + return_quantity
    
    update_product(product, %{stock_quantity: new_stock})
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, product} ->
        {:ok, Repo.preload(product, :categories)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, product_updated} ->
        {:ok, Repo.preload(product_updated, :categories)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    category_ids =
      Map.get(attrs, "category_ids", [])

    categories =
      list_categories_by_id(category_ids)

    product
    |> Repo.preload(:categories)
    |> Product.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:categories, categories)
  end

  def list_categories_by_id(nil), do: []

  def list_categories_by_id(category_ids) do
    Repo.all(from c in Category, where: c.id in ^category_ids)
  end

  def put_image_url(product_id, image_url) do
    case Repo.get(Product, product_id) do
      %Product{} = product ->
        product_with_image =
          product
          |> Product.image_url_changeset(%{image_url: image_url})
          |> Repo.update()

        product_with_image

      nil ->
        nil
    end
  end

  def get_product_rating(product_id) do
    query = from r in ProductReview,
            where: r.product_id == ^product_id,
            select: avg(r.review)
    
    case Repo.one(query) do
      nil -> 0.0  # Nenhuma avaliação encontrada
      average -> 
        average
        |> Decimal.to_float()
        |> Float.round(1)  # Arredonda para 1 casa decimal
    end
  end

end
