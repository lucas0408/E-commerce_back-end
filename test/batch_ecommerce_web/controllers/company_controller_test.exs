defmodule BatchEcommerceWeb.CompanyControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures
  
  import BatchEcommerce.Factory

  alias BatchEcommerce.Accounts.{Company, Guardian}

  @create_attrs %{
    cnpj: "11111111111111",
    email: "murilo@hotmail.com",
    name: "some name",
    phone_number: "11979897989",
    user_id: nil,
    addresses: [
      %{
        address: "rua elixir",
        cep: "09071000",
        uf: "SP",
        city: "cidade java",
        district: "vila programação",
        complement: "casa",
        home_number: "321"
      }
    ]
  }

  @update_attrs %{
    cnpj: "11111111111111",
    email: "updateemail@hotmail.com",
    name: "some update name",
    phone_number: "11979897989",
    user_id: nil,
    addresses: [
      %{
        address: "some update address",
        cep: "09071000",
        uf: "SP",
        city: "some update city",
        district: "vila programação",
        complement: "casa",
        home_number: "321"
      }
    ]
  }
  @invalid_attrs %{name: nil, cnpj: nil, email: nil, phone_number: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_secssion_company]

    test "lists all companies", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/companies")
      response_data = json_response(conn, 200)["data"] |> Enum.at(0)
      IO.inspect(response_data)
      assert response_data["id"] == company.id
      assert response_data["name"] == company.name
      assert response_data["cnpj"] == company.cnpj
      assert response_data["email"] == company.email
      assert response_data["phone_number"] == company.phone_number
      assert response_data["user_id"] == company.user_id
      assert length(response_data["addresses"]["data"]) == length(company.addresses)

      Enum.each(Enum.zip(response_data["addresses"]["data"], company.addresses), fn {address_response, address_params} ->
        assert address_response["address"] == address_params.address
        assert address_response["cep"] == address_params.cep
        assert address_response["uf"] == address_params.uf
        assert address_response["city"] == address_params.city
        assert address_response["district"] == address_params.district
        assert address_response["complement"] == address_params.complement
        assert address_response["home_number"] == address_params.home_number
      end)
    end
  end

  describe "create company" do
    setup [:create_session]

    test "renders company when data is valid", %{conn: conn, user: user} do
      user_id = user.id
      conn = post(conn, ~p"/api/companies", company: %{@create_attrs | user_id: user_id})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/companies/#{id}")

      company = BatchEcommerce.Accounts.get_company(id)

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["cnpj"] == "11111111111111"
      assert response_data["email"] == "murilo@hotmail.com"
      assert response_data["name"] == "some name"
      assert response_data["phone_number"] == "11979897989"
      assert length(response_data["addresses"]["data"]) == length(company.addresses)

      Enum.each(response_data["addresses"]["data"], fn address ->
        assert Map.has_key?(address, "address")
        assert Map.has_key?(address, "cep")
        assert Map.has_key?(address, "uf")
        assert Map.has_key?(address, "city")
        assert Map.has_key?(address, "district")
        assert Map.has_key?(address, "complement")
        assert Map.has_key?(address, "home_number")
      end)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/companies", company: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update company" do
    setup [:create_secssion_company]

    test "renders company when data is valid", %{
      conn: conn,
      company: %Company{id: id} = company,
      user: user
    } do
      conn =
        put(conn, ~p"/api/companies/#{company}", company: %{@update_attrs | user_id: user.id})

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/companies/#{id}")

      company = BatchEcommerce.Accounts.get_company(id)

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["cnpj"] == "11111111111111"
      assert response_data["email"] == "updateemail@hotmail.com"
      assert response_data["name"] == "some update name"
      assert response_data["phone_number"] == "11979897989"
      assert length(response_data["addresses"]["data"]) == length(company.addresses)

      Enum.each(response_data["addresses"]["data"], fn address ->
        assert Map.has_key?(address, "address")
        assert Map.has_key?(address, "cep")
        assert Map.has_key?(address, "uf")
        assert Map.has_key?(address, "city")
        assert Map.has_key?(address, "district")
        assert Map.has_key?(address, "complement")
        assert Map.has_key?(address, "home_number")
      end)
    end

    test "renders errors when data is invalid", %{conn: conn, company: company} do
      conn = put(conn, ~p"/api/companies/#{company}", company: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete company" do
    setup [:create_secssion_company]

    test "deletes chosen company", %{conn: conn, company: company} do
      conn = delete(conn, ~p"/api/companies/#{company}")
      assert response(conn, 204)
    end
  end

  defp create_secssion_company(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    IO.inspect(user.id)
    company = insert(:company, user_id: user.id)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), company: company}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
