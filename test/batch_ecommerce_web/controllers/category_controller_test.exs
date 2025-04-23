defmodule BatchEcommerceWeb.CategoryControllerTest do
  @moduledoc """
  The Category test module.
  """
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.{CatalogFixtures, AccountsFixtures}

  import BatchEcommerce.Factory

  alias BatchEcommerce.Catalog.Category
  alias BatchEcommerce.Accounts.Guardian

  @create_attrs %{
    type: "roupas"
  }

  @update_attrs %{
    type: "ferramentas"
  }

  @invalid_attrs %{type: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_session]

    test "lists all categories", %{conn: conn, category: category} do
      conn = get(conn, ~p"/api/categories")
      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == category.id
    end
  end

  describe "create category" do
    setup [:create_session]

    test "renders category when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/categories", category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "type" => "roupas"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/categories", category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_session]

    test "renders category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = category
    } do
      conn = put(conn, ~p"/api/categories/#{category}", category: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      assert %{
               "id" => ^id,
               "type" => "ferramentas"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/api/categories/#{category}", category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category" do
    setup [:create_session]

    test "deletes chosen category", %{conn: conn, category: category} do
      conn = delete(conn, ~p"/api/categories/#{category}")
      assert response(conn, 204)

      conn = get(conn, ~p"/api/categories/#{category}")
      assert conn.status == 404
    end
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    category = category_fixture()
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), category: category}
  end
end
