defmodule BatchEcommerce.CatalogTest do
  use BatchEcommerce.DataCase, async: true

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  import BatchEcommerce.CatalogFixtures
  import Hammox

  describe "categories" do
    alias BatchEcommerce.Catalog.Category

    @invalid_attrs %{type: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Catalog.list_categories() == [category]
    end

    test "get_category/1 returns the category with given id" do
      category = category_fixture()

      assert {:ok, category_found} = Catalog.get_category(category.id)
      assert category_found == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{type: "roupas"}

      assert {:ok, %Category{} = category} = Catalog.create_category(valid_attrs)
      assert category.type == "roupas"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{type: "ferramentas"}

      assert {:ok, %Category{} = category} = Catalog.update_category(category, update_attrs)
      assert category.type == "ferramentas"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()

      assert {:error, %Ecto.Changeset{}} = Catalog.update_category(category, @invalid_attrs)
      assert {:ok, %Category{} = category} == Catalog.get_category(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()

      assert {:ok, %Category{}} = Catalog.delete_category(category)
      assert {:error, :not_found} = Catalog.get_category(category.id)
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Catalog.change_category(category)
    end
  end

  describe "products" do
    setup [:create_image]
    alias BatchEcommerce.Catalog.Product

    import BatchEcommerce.CatalogFixtures

    @invalid_attrs %{name: nil, price: nil, stock_quantity: nil, image_url: nil}

    test "list_products/0 returns all products", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})
      assert Catalog.list_products() == [product]
    end

    test "get_product/1 returns the product with given id", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})
      assert {:ok, %Product{} = product_found} = Catalog.get_product(product.id)
      assert product_found == product
    end

    test "create_product/1 with valid data creates a product", %{image_url: image_url} do
      valid_attrs = %{name: "some name", price: "120.5", stock_quantity: 42, image_url: image_url}

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})

      update_attrs = %{
        name: "some updated name",
        price: "456.7",
        stock_quantity: 43,
        image_url: "some updated url_image"
      }

      assert {:ok, %Product{} = product} = Catalog.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43
      assert product.image_url == "some updated url_image"
    end

    test "update_product/2 with invalid data returns error changeset", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})
      assert {:error, %Ecto.Changeset{}} = Catalog.update_product(product, @invalid_attrs)
      assert {:ok, product} == Catalog.get_product(product.id)
    end

    test "delete_product/1 deletes the product", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert {:error, :not_found} == Catalog.get_product(product.id)
    end

    test "change_product/1 returns a product changeset", %{image_url: image_url} do
      product = product_fixture(%{image_url: image_url})
      assert %Ecto.Changeset{} = Catalog.change_product(product)
    end
  end

  describe "products with category associated" do
    setup [:create_categories, :create_image]

    test "get product returns the product with given id and preloaded category", %{
      image_url: image_url
    } do
      product = product_fixture_assoc(%{image_url: image_url})
      assert {:ok, %Product{} = product_found} = Catalog.get_product(product.id)
      assert product_found == product
    end

    test "create product with categories associated", %{
      categories: categories,
      image_url: image_url
    } do
      category_ids = Enum.map(categories, & &1.id)

      valid_attrs = %{
        name: "some name",
        price: "120.5",
        stock_quantity: 42,
        image_url: image_url,
        category_ids: category_ids
      }

      assert {:ok, %Product{} = product} = Catalog.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock_quantity == 42
      assert product.image_url == "http://localhost:9000/test-bucket/test.jpg"

      assert product.categories ==
               Enum.map(product.categories, fn category ->
                 {:ok, category_return} = Catalog.get_category(category.id)
                 category_return
               end)
    end

    test "update product with categories associated", %{
      categories: categories,
      image_url: image_url
    } do
      category_ids = Enum.map(categories, & &1.id)

      update_attrs = %{
        name: "some updated name",
        price: "456.7",
        stock_quantity: 43,
        image_url: "some updated image_url",
        category_ids: category_ids
      }

      product_assoc = product_fixture_assoc(%{image_url: image_url})

      assert {:ok, %Product{} = product} = Catalog.update_product(product_assoc, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock_quantity == 43
      assert product.image_url == "some updated image_url"

      assert product.categories ==
               Enum.map(product.categories, fn category ->
                 {:ok, category_return} = Catalog.get_category(category.id)
                 category_return
               end)
    end

    test "delete_product/1 deletes the product", %{image_url: image_url} do
      product = product_fixture_assoc(%{image_url: image_url})
      assert {:ok, %Product{}} = Catalog.delete_product(product)
      assert {:error, :not_found} == Catalog.get_product(product.id)
    end
  end

  defp create_categories(_) do
    category_1 = category_fixture(%{type: "roupas"})
    category_2 = category_fixture(%{type: "sapatos"})

    %{categories: [category_1, category_2]}
  end

  defp create_image(_) do
    tmp_path = Path.join(System.tmp_dir!(), "test.jpg")
    File.write!(tmp_path, "test-content")

    upload = %{
      filename: "test.jpg",
      path: tmp_path
    }

    on_exit(fn ->
      File.rm(tmp_path)
    end)

    expect(BatchEcommerce.Catalog.MockMinio, :upload_file, fn ^upload, "test-bucket" ->
      {:ok, "http://localhost:9000/test-bucket/test.jpg"}
    end)

    {:ok, image_url} =
      BatchEcommerce.Catalog.MockMinio.upload_file(upload, "test-bucket")

    {:ok, %{image_url: image_url}}
  end
end
