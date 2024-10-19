defmodule BatchEcommerceWeb.AddressControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.Address

  @create_attrs %{
    address: "some address",
    cep: "some cep",
    uf: "some uf",
    city: "some city",
    district: "some district",
    complement: "some complement",
    home_number: "some home_number"
  }
  @update_attrs %{
    address: "some updated address",
    cep: "some updated cep",
    uf: "some updated uf",
    city: "some updated city",
    district: "some updated district",
    complement: "some updated complement",
    home_number: "some updated home_number"
  }
  @invalid_attrs %{address: nil, cep: nil, uf: nil, city: nil, district: nil, complement: nil, home_number: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all addresses", %{conn: conn} do
      conn = get(conn, ~p"/api/addresses")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create address" do
    test "renders address when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/addresses", address: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/addresses/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some address",
               "cep" => "some cep",
               "city" => "some city",
               "complement" => "some complement",
               "district" => "some district",
               "home_number" => "some home_number",
               "uf" => "some uf"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/addresses", address: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update address" do
    setup [:create_address]

    test "renders address when data is valid", %{conn: conn, address: %Address{id: id} = address} do
      conn = put(conn, ~p"/api/addresses/#{address}", address: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/addresses/#{id}")

      assert %{
               "id" => ^id,
               "address" => "some updated address",
               "cep" => "some updated cep",
               "city" => "some updated city",
               "complement" => "some updated complement",
               "district" => "some updated district",
               "home_number" => "some updated home_number",
               "uf" => "some updated uf"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, address: address} do
      conn = put(conn, ~p"/api/addresses/#{address}", address: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete address" do
    setup [:create_address]

    test "deletes chosen address", %{conn: conn, address: address} do
      conn = delete(conn, ~p"/api/addresses/#{address}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/addresses/#{address}")
      end
    end
  end

  defp create_address(_) do
    address = address_fixture()
    %{address: address}
  end
end
