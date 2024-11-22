defmodule BatchEcommerce.CatalogTest do
  use BatchEcommerce.DataCase

  alias BatchEcommerce.Catalog

  describe "categories" do
    alias BatchEcommerce.Catalog.Category

    import BatchEcommerce.CatalogFixtures

    @invalid_attrs %{type: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

    test "get_category/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.type == "some type"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{type: "some updated type"}

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.type == "some updated type"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert category == Catalog.get_category(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert Catalog.get_category(category.id) == {:error, :not_found}
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    alias BatchEcommerce.Catalog.Product

    import BatchEcommerce.CatalogFixtures

    @invalid_attrs %{name: nil, price: nil, stock_quantity: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", price: "120.5", stock_quantity: 42}

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", price: "456.7", stock_quantity: 43}

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert product == Catalog.get_product(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert Catalog.get_product(product.id) == {:error, :not_found}
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end
end
