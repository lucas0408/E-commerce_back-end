defmodule BatchEcommerce.CatalogTest do
<<<<<<< HEAD
  @moduledoc """
  The Catalog test module.
  """

  use BatchEcommerce.DataCase, async: true

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.{Product, Category}
  import BatchEcommerce.CatalogFixtures

  describe "categories" do
=======
  use BatchEcommerce.DataCase

  alias BatchEcommerce.Catalog

  describe "categories" do
    alias BatchEcommerce.Catalog.Category

    import BatchEcommerce.CatalogFixtures

>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    @invalid_attrs %{type: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

<<<<<<< HEAD
    test "get_category/1 returns the category with given id" do
      category = category_fixture()

      assert %Category{} = category_found = Catalog.get_category(category.id)
      assert category_found == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{type: "roupas"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.type == "roupas"
=======
    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Catalog.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{type: "some type"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.type == "some type"
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
<<<<<<< HEAD
      update_attrs = %{type: "ferramentas"}

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.type == "ferramentas"
=======
      update_attrs = %{type: "some updated type"}

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.type == "some updated type"
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
<<<<<<< HEAD

      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert category == Catalog.get_category(category.id)
=======
      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert category == Catalog.get_category!(category.id)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
<<<<<<< HEAD

      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert Catalog.get_category(category.id) == nil
=======
      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_category!(category.id) end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    alias BatchEcommerce.Catalog.Product

    import BatchEcommerce.CatalogFixtures

<<<<<<< HEAD
    @invalid_attrs %{name: nil, price: nil, stock_quantity: nil, description: nil}

    test "list_products/0 returns all products" do
      product = product_fixture_assoc(%{}, %{type: "roupas"})

      products = Catalog.list_products()
      # IO.inspect(products)
    end

    test "get_product/1 returns the product with given id" do
      product = product_fixture()
      assert %Product{} = product_found = Catalog.get_product(product.id)
      assert product_found == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{
        name: "some name",
        price: "120.5",
        stock_quantity: 42,
        description: "some description"
      }
=======
    @invalid_attrs %{name: nil, price: nil, stock_quantity: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Catalog.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", price: "120.5", stock_quantity: 42}
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42
<<<<<<< HEAD
      assert product.description == "some description"
=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
<<<<<<< HEAD

      update_attrs = %{
        name: "some updated name",
        price: "456.7",
        stock_quantity: 43
      }
=======
      update_attrs = %{name: "some updated name", price: "456.7", stock_quantity: 43}
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
<<<<<<< HEAD
      assert product == Catalog.get_product(product.id)
=======
      assert product == Catalog.get_product!(product.id)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
<<<<<<< HEAD
      assert Catalog.get_product(product.id) == nil
=======
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_product!(product.id) end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end
<<<<<<< HEAD

  describe "products with category associated" do
    setup [:create_categories]

    test "get product returns the product with given id and preloaded category", %{} do
      product = product_fixture_assoc()
      assert %Product{} = product_found = Catalog.get_product(product.id)
      assert product_found == product
    end

    test "create product with categories associated", %{
      categories: categories
    } do
      category_ids = Enum.map(categories, & &1.id)

      valid_attrs = %{
        name: "some name",
        price: "120.5",
        stock_quantity: 42,
        category_ids: category_ids,
        description: "some description"
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42

      assert product.categories ==
               Enum.map(product.categories, fn category ->
                 %Category{} = category_return = Catalog.get_category(category.id)
                 category_return
               end)
    end

    test "update product with categories associated", %{
      categories: categories
    } do
      category_ids = Enum.map(categories, & &1.id)

      update_attrs = %{
        name: "some updated name",
        price: "456.7",
        stock_quantity: 43,
        category_ids: category_ids
      }

      product_assoc = product_fixture_assoc()

      assert {:ok, %Product{} = product} = Catalog.update_product(product_assoc, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43

      assert product.categories ==
               Enum.map(product.categories, fn category ->
                 %Category{} = category_return = Catalog.get_category(category.id)
                 category_return
               end)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture_assoc()
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert Catalog.get_product(product.id) == nil
    end
  end

  defp create_categories(_) do
    category_1 = category_fixture(%{type: "roupas"})
    category_2 = category_fixture(%{type: "sapatos"})

    %{categories: [category_1, category_2]}
  end
=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
end
