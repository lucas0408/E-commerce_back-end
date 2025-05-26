defmodule BatchEcommerce.CatalogTest do
  @moduledoc """
  The Catalog test module.
  """

  use BatchEcommerce.DataCase, async: true

  import BatchEcommerce.Factory

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.{Product, Category}

  describe "categories" do

    test "list_categories/0 returns all categories" do
      inserted_categories = insert_list(3, :category)
      category_list = Catalog.list_categories()

      assert inserted_categories == category_list
    end

    test "get_category/1 returns the category with given id" do
      category = insert(:category)

      found_category = Catalog.get_category(category.id)

      assert category = found_category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = params_for(:category)

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      
      assert category.type == valid_attrs.type
    end

    test "create_category/1 with invalid data returns error changeset" do
      invalid_attrs = invalid_params_for(:category, [:type])
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      update_attrs = params_for(:category)
      category = insert(:category)

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)

      assert category.type == update_attrs.type
    end

    test "update_category/2 with invalid data returns error changeset" do
      invalid_attrs = invalid_params_for(:category, [:type])
      category = insert(:category)

      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, invalid_attrs)
      assert category == Catalog.get_category(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = insert(:category)

      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert Catalog.get_category(category.id) == nil
    end

    test "change_category/1 returns a category changeset" do
      category = insert(:category)
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    alias BatchEcommerce.Catalog.Product

    test "list_products/0 returns all products" do
      list_products = insert_list(5, :product)

      assert list_products = Catalog.list_products()
    end

    test "get_product/1 returns the product with given id" do
      product = insert(:product)
      found_product = Catalog.get_product(product.id)

      assert product == found_product
    end

    test "create_product/1 with valid data creates a product" do      
      valid_attrs = params_for(:product)
      
      valid_attrs = %{valid_attrs | categories: []}
      
      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      
      get_product = Catalog.get_product(product.id)
      
      assert product.name == valid_attrs.name
      assert product.price == Decimal.new("#{valid_attrs.price}")
      assert product.stock_quantity == valid_attrs.stock_quantity
      assert product.description == valid_attrs.description
      
      product.categories == []
    end

    test "create_product/1 with invalid data returns error changeset" do
      invalid_params = invalid_params_for(:product, [:name, :price, :stock_quantity, :description, :company_id])
      
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(invalid_params)
    end

    test "update_product/2 with valid data update the product" do
      valid_attrs = params_for(:product)
      
      valid_attrs = %{valid_attrs | categories: []}
      
      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)

      update_attrs = params_for(:product)

      assert {:ok, %Product{} = update_product} = Catalog.update_product(product, update_attrs)

      assert update_product.name == update_attrs.name
      assert update_product.price == Decimal.new("#{update_attrs.price}")
      assert update_product.stock_quantity == update_attrs.stock_quantity
      assert update_product.description == update_attrs.description
      
      update_product.categories == []

      assert update_product.name != product.name
    end

    test "update_product/2 with invalid data returns error changeset" do
      invalid_attrs = invalid_params_for(:product, [:name, :price, :stock_quantity, :description, :company_id])
      product = insert(:product)

      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, invalid_attrs)
      assert product == Catalog.get_product(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = insert(:product)
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert Catalog.get_product(product.id) == nil
    end

    test "change_product/1 returns a product changeset" do
      product = insert(:product)
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end

  describe "products with category associated" do

    test "get product returns the product with given id and preloaded category", %{} do
      product = insert(:product)
      assert %Product{} = product_found = Catalog.get_product(product.id)
      assert product_found.categories == product.categories
    end

    test "create product with categories associated", %{
      categories: categories
    } do
      company = insert(:company)
      category_ids = Enum.map(categories, & &1.id)

      valid_attrs = %{
        name: "some name",
        price: "120.5",
        stock_quantity: 42,
        category_ids: category_ids,
        company_id: company.id,
        description: "some description"
      }

      category_ids = Enum.map(categories, fn category -> category.id end)

      update_attrs = params_for(:product)

      update_attrs_product = %{update_attrs | categories: category_ids}

      product = insert(:product)

      assert {:ok, %Product{} = update_product} = Catalog.update_product(product, Map.new(update_attrs_product, fn {key, val} -> {Atom.to_string(key), val} end))
      assert update_product.name == update_attrs.name
      assert update_product.price == Decimal.from_float(update_attrs.price)
      assert update_product.stock_quantity == update_attrs.stock_quantity

      assert product.categories != update_product.categories

      assert update_product.categories == categories
    end

    test "delete_product/1 deletes the product" do
      product = insert(:product)
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert Catalog.get_product(product.id) == nil
    end
  end
end
