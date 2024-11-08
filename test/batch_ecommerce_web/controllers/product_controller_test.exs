defmodule BatchEcommerceWeb.ProductControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.CatalogFixtures

  alias BatchEcommerce.Catalog.Product

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.{User, Guardian}

  @create_attrs %{
    name: "some name",
    price: "120.5",
    stock_quantity: 42,
    category_id: nil
  }

  @update_attrs %{
    name: "some updated name",
    price: "456.7",
    stock_quantity: 43,
    category_id: nil
  }

  @invalid_attrs %{
    name: nil,
    price: nil,
    stock_quantity: nil,
    category_id: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_product]
    test "lists all products", %{conn: conn, product: product} do
      conn = get(conn, ~p"/api/products")
      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == product.id
    end
  end

  describe "create product" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = Guardian.Plug.sign_in(conn, user)
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      %{conn: put_req_header(conn, "authorization", "Bearer #{token}")}
    end
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: %{@create_attrs | category_id: category_fixture().id})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
               "id" => ^id,
               "name" => "some name",
               "price" => "120.5",
               "stock_quantity" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, ~p"/api/products/#{product}", product: %{@update_attrs | category_id: product.category_id})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
        "id" => ^id,
        "name" => "some updated name",
        "price" => "456.7",
        "stock_quantity" => 43,

        } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, ~p"/api/products/#{product}", product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, ~p"/api/products/#{product}")
      assert response(conn, 204)
    end
  end

  defp create_product(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    product = product_fixture()
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), product: product}
  end
end
