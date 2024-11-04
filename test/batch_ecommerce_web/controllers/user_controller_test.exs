defmodule BatchEcommerceWeb.UserControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.{User, Guardian}

  @create_attrs %{
    cpf: "52511111111",
    name: "murilo",
    email: "murilo@hotmail.com",
    phone_number: "11979897989",
    birth_date: "2004-05-06",
    password: "password",
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
    cpf: "52511111111",
    name: "murilo updated",
    email: "murilo@hotmail.com",
    phone_number: "11979897989",
    birth_date: "2005-05-06",
    address: %{
      address: "rua python",
      cep: "09071001",
      uf: "MG",
      city: "cidade ruby",
      district: "vila destruição",
      complement: "apartamento",
      home_number: "123"
    }
  }

  @invalid_attrs %{
    cpf: nil,
    name: nil,
    email: nil,
    phone_number: nil,
    birth_date: nil,
    password: nil,
    address: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  # review
  describe "index" do
    setup [:create_session]

    test "lists all users", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 302)["data"] |> Enum.at(0) |> Map.get("id") == user.id
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "cpf" => "52511111111",
               "name" => "murilo",
               "email" => "murilo@hotmail.com",
               "phone_number" => "11979897989",
               "birth_date" => "2004-05-06",
               "address" => %{
                 "address" => "rua elixir",
                 "cep" => "09071000",
                 "uf" => "SP",
                 "city" => "cidade java",
                 "district" => "vila programação",
                 "complement" => "casa",
                 "home_number" => "321"
               }
             } = json_response(conn, 302)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_session]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "cpf" => "52511111111",
               "name" => "murilo updated",
               "email" => "murilo@hotmail.com",
               "phone_number" => "11979897989",
               "birth_date" => "2005-05-06",
               "password" => "password",
               "address" => %{
                 "address" => "rua python",
                 "cep" => "09071001",
                 "uf" => "MG",
                 "city" => "cidade ruby",
                 "district" => "vila destruição",
                 "complement" => "apartamento",
                 "home_number" => "123"
               }
             } = json_response(conn, 302)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_session]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/users/#{user}")
      end
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
