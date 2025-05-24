defmodule BatchEcommerceWeb.CategoryControllerTest do
  @moduledoc """
  The Category test module.
  """
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.{CatalogFixtures, AccountsFixtures}

  import BatchEcommerce.Factory

  alias BatchEcommerce.Catalog.Category
  alias BatchEcommerce.Accounts.Guardian

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  setup do
    category = insert(:category)
    %{category: category}
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
      category_attrs = params_for(:category)
      conn = post(conn, ~p"/api/categories", category: category_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/categories/#{id}")

      category_attrs_type = category_attrs.type

      assert %{
               "type" => category_attrs_type
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/categories", category: invalid_params_for(:category, [:type]))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_session]

    test "renders category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = category
    } do
      conn = put(conn, ~p"/api/categories/#{category}", category: params_for(:category))
      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    
      conn = get(conn, ~p"/api/categories/#{id}")

      assert category.type != json_response(conn, 200)["data"]["type"]
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/api/categories/#{category}", category: invalid_params_for(:category, [:type]))
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
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
