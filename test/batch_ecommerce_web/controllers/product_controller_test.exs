defmodule BatchEcommerceWeb.ProductControllerTest do
<<<<<<< HEAD
  @moduledoc """
  The Product controller test module.
  """
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.CatalogFixtures
  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Accounts.Guardian

  @update_attrs %{
    name: "some updated name",
    price: "456.7",
    stock_quantity: 43,
    image_url: "some updated image_url",
    description: "some description"
  }
  @invalid_attrs %{name: nil, price: nil, stock_quantity: nil, categories: nil, image_url: nil}
=======
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.CatalogFixtures

  alias BatchEcommerce.Catalog.Product

  @create_attrs %{
    name: "some name",
    price: "120.5",
    stock_quantity: 42
  }
  @update_attrs %{
    name: "some updated name",
    price: "456.7",
    stock_quantity: 43
  }
  @invalid_attrs %{name: nil, price: nil, stock_quantity: nil}
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
<<<<<<< HEAD
    setup [:create_session]

=======
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    test "lists all products", %{conn: conn} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
<<<<<<< HEAD
    setup [:create_session, :create_product_params]

    test "renders product when data is valid", %{conn: conn, product: product} do
      conn = post(conn, ~p"/api/products", product: product)
=======
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

<<<<<<< HEAD
      %Product{} = product_preloaded = Catalog.get_product(id)

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["name"] == "some name"
      assert response_data["price"] == "120.5"
      assert response_data["stock_quantity"] == 42

      assert length(response_data["categories"]["data"]) == length(product_preloaded.categories)

      Enum.each(response_data["categories"]["data"], fn category ->
        assert Map.has_key?(category, "id")
        assert Map.has_key?(category, "type")
      end)
=======
      assert %{
               "id" => ^id,
               "name" => "some name",
               "price" => "120.5",
               "stock_quantity" => 42
             } = json_response(conn, 200)["data"]
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
<<<<<<< HEAD
    setup [:create_session, :create_product]
=======
    setup [:create_product]
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some updated name",
               "price" => "456.7",
               "stock_quantity" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
<<<<<<< HEAD
    setup [:create_session, :create_product]
=======
    setup [:create_product]
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)

<<<<<<< HEAD
      conn = get(conn, ~p"/api/products/#{product}")
      assert conn.status == 404
=======
      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product}")
      end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
    end
  end

  defp create_product(_) do
<<<<<<< HEAD
    product = BatchEcommerce.CatalogFixtures.product_fixture()
    %{product: product}
  end

  defp create_product_params(_) do
    category_1 = category_fixture(%{type: "roupas"})
    category_2 = category_fixture(%{type: "sapatos"})
    categories = [category_1, category_2]
    category_ids = Enum.map(categories, & &1.id)

    product = %{
      name: "some name",
      price: "120.5",
      stock_quantity: 42,
      category_ids: category_ids,
      description: "some description"
    }

    %{product: product}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
=======
    product = product_fixture()
    %{product: product}
  end
>>>>>>> dac2a36e6514df7d84a6025e1707caff2be550c9
end
