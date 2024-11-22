defmodule BatchEcommerceWeb.CompanyControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.{Company, Guardian}

  @create_attrs %{
      cnpj: "11111111111111",
      email: "murilo@hotmail.com",
      name: "some name",
      phone_number: "11979897989",
      user_id: nil,
      address: %{
        address: "rua elixir",
        cep: "09071000",
        uf: "SP",
        city: "cidade java",
        district: "vila programação",
        complement: "casa",
        home_number: "321"
      }
    }

  @update_attrs %{
    cnpj: "11111111111111",
    email: "updateemail@hotmail.com",
    name: "some update name",
    phone_number: "11979897989",
    user_id: nil,
    address: %{
      address: "some update address",
      cep: "09071000",
      uf: "SP",
      city: "some update city",
      district: "vila programação",
      complement: "casa",
      home_number: "321"
    }
  }
  @invalid_attrs %{name: nil, cnpj: nil, email: nil, phone_number: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_secssion_company]
    test "lists all companies", %{conn: conn, company: company} do
      conn = get(conn, ~p"/api/companies")
      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == company.id
    end
  end

  describe "create company" do
    setup [:create_session]

    test "renders company when data is valid", %{conn: conn, user: user} do
      user_id = user.id
      conn = post(conn, ~p"/api/companies", company: %{@create_attrs | user_id: user_id})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/companies/#{id}")

      assert %{
        "cnpj" => "11111111111111",
        "email" => "murilo@hotmail.com",
        "name" => "some name",
        "phone_number" => "11979897989",
        "address" => %{
          "address" => "rua elixir",
          "cep" => "09071000",
          "uf" => "SP",
          "city" => "cidade java",
          "district" => "vila programação",
          "complement" => "casa",
          "home_number" => "321"
        }
      } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/companies", company: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update company" do
    setup [:create_secssion_company]

    test "renders company when data is valid", %{conn: conn, company: %Company{id: id} = company, user: user} do
      conn = put(conn, ~p"/api/companies/#{company}", company: %{@update_attrs | user_id: user.id})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/companies/#{id}")

      assert %{"id" => ^id,
                "cnpj" => "11111111111111",
                "email" => "updateemail@hotmail.com",
                "name" => "some update name",
                "phone_number" => "11979897989",
                "address" => %{
                  "address" => "some update address",
                  "cep" => "09071000",
                  "uf" => "SP",
                  "city" => "some update city",
                  "district" => "vila programação",
                  "complement" => "casa",
                  "home_number" => "321"
                }
              } = json_response(conn, 200)["data"]
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
    company = company_fixture(user.id)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), company: company, user: user}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
