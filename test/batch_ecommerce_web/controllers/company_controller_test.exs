defmodule BatchEcommerceWeb.CompanyControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures
  
  import BatchEcommerce.Factory

  alias BatchEcommerce.Accounts.{Company, Guardian}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_secssion_company]

    test "lists all companies", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/companies")
      response_data = json_response(conn, 200)["data"] |> Enum.at(0)

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
      conn = post(conn, ~p"/api/companies", company: company_params = params_for(:company))
      response_data = json_response(conn, 201)["data"]

      assert response_data["cnpj"] == company_params.cnpj
      assert response_data["email"] == company_params.email
      assert response_data["name"] == company_params.name
      assert response_data["phone_number"] == company_params.phone_number
      assert length(response_data["addresses"]["data"]) == length(company_params.addresses)

      Enum.each(Enum.zip(response_data["addresses"]["data"], company_params.addresses), fn {address_response, address_params} ->
        assert address_response["address"] == address_params.address
        assert address_response["cep"] == address_params.cep
        assert address_response["uf"] == address_params.uf
        assert address_response["city"] == address_params.city
        assert address_response["district"] == address_params.district
        assert address_response["complement"] == address_params.complement
        assert address_response["home_number"] == address_params.home_number
      end)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/companies", company: invalid_params_for(:company, [:name, :cnpj, :email]))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update company" do
    setup [:create_secssion_company]

    test "renders company when data is valid", %{conn: conn, company: company} do
      conn =
        put(conn, ~p"/api/companies/#{company}", company: params_for(:company, user_id: company.user_id))

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == company.id
      assert response_data["cnpj"] != company.cnpj
      assert response_data["email"] != company.email
      assert response_data["name"] != company.name
      assert response_data["phone_number"] != company.phone_number
      assert length(response_data["addresses"]["data"]) == length(company.addresses)

      Enum.each(Enum.zip(response_data["addresses"]["data"], company.addresses), fn {address_response, address_params} ->
        assert address_response["address"] != address_params.address
        assert address_response["cep"] != address_params.cep
        assert address_response["uf"] != address_params.uf
        assert address_response["city"] != address_params.city
        assert address_response["district"] != address_params.district
        assert address_response["complement"] != address_params.complement
        assert address_response["home_number"] != address_params.home_number
      end)
    end

    test "renders errors when data is invalid", %{conn: conn, company: company} do
      conn = put(conn, ~p"/api/companies/#{company}", company: invalid_params_for(:company, [:name, :cnpj, :email]))
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
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    company = insert(:company, user_id: user.id)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)

    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), company: company}
  end

  defp create_session(%{conn: conn}) do
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
