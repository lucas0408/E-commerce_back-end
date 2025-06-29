defmodule BatchEcommerceWeb.ProductControllerTest do
  @moduledoc """
  The Product controller test module.
  """
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.Factory

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog.Category
  alias BatchEcommerce.Accounts.Guardian

  @update_attrs %{
    name: "some updated name",
    price: "456.7",
    stock_quantity: 43,
    filename: "some updated filename",
    description: "some description"
  }
  @invalid_attrs %{name: nil, price: nil, stock_quantity: nil, categories: nil, filename: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup do
    invalid_attrs = invalid_params_for(:product, [:name, :price, :stock_quantity, :description, :company_id])
    %{invalid_attrs: invalid_attrs}
  end

  setup do
    product = insert(:product)
    %{product: product}
  end

  describe "index" do
    setup [:create_session]

    test "lists all products", %{conn: conn, product: product} do

      conn = get(conn, ~p"/api/products")
      assert response_data = hd(json_response(conn, 200)["data"])

      assert product.company_id == response_data["company_id"]

      assert product.description == response_data["description"]

      assert product.id == response_data["id"]

      assert product.filename == response_data["filename"]

      assert product.name == response_data["name"]

      assert product.price == Decimal.new(response_data["price"])

      assert product.stock_quantity == response_data["stock_quantity"]
    end
  end

  describe "create product" do
    setup [:create_session]
    test "renders product when data is valid", %{conn: conn} do
      categories = insert_list(2, :category)
      category_ids = Enum.map(categories, fn category -> category.id end)
      product = params_for(:product, [categories: category_ids])

      conn = post(conn, ~p"/api/products", product: product)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      %Product{} = product_preloaded = Catalog.get_product(id)

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["name"] == product.name
      assert response_data["price"] == "#{product.price}"
      assert response_data["stock_quantity"] == product.stock_quantity

      assert Enum.zip(response_data["categories"]["data"], categories)
      |> Enum.all?(fn {category_data, %Category{id: id2, type: type2}} ->
             category_data["id"] == id2 and category_data["type"] == type2 end)
    end

    test "renders errors when data is invalid", %{conn: conn, invalid_attrs: invalid_attrs} do
      conn = post(conn, ~p"/api/products", product: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_session]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do

      update_attrs = params_for_product()

      conn = put(conn, ~p"/api/products/#{product}", product: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      response_data = json_response(conn, 200)["data"]

      assert product.id == response_data["id"]

      assert product.company_id != response_data["company_id"]

      assert product.filename != response_data["filename"]

      assert product.name != response_data["name"]

    end

    test "renders errors when data is invalid", %{conn: conn, product: product, invalid_attrs: invalid_attrs} do
      conn = put(conn, ~p"/api/products/#{product}", product: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_session]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/products/#{product}")
      assert conn.status == 404
    end
  end

  defp create_session(%{conn: conn}) do
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
