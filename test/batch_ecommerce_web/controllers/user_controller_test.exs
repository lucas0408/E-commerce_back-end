defmodule BatchEcommerceWeb.UserControllerTest do
  use BatchEcommerceWeb.ConnCase

  import BatchEcommerce.AccountsFixtures

  alias BatchEcommerce.Accounts.User
  alias BatchEcommerce.Accounts

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
    password: "password",
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
    {:ok, user} =
      %{
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
      |> Accounts.create_user()

    {:ok, token, _claims} = BatchEcommerce.Accounts.Guardian.encode_and_sign(user)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user, token: token}
  end

  # review
  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      [users] = conn.assigns[:users]
      assert json_response(conn, 302)["data"] == [users]
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
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "address_id" => 43,
               "cpf" => "some updated cpf",
               "email" => "some updated email",
               "name" => "some updated name",
               "password_hash" => "some updated password_hash",
               "phone" => "some updated phone"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

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
end
