defmodule BatchEcommerceWeb.UserControllerTest do
  use BatchEcommerceWeb.ConnCase, async: true

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

  describe "index" do
    setup [:create_session]

    test "lists all users", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users")
      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == user.id
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
             } = json_response(conn, 200)["data"]
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
               "address" => %{
                 "address" => "rua python",
                 "cep" => "09071001",
                 "uf" => "MG",
                 "city" => "cidade ruby",
                 "district" => "vila destruição",
                 "complement" => "apartamento",
                 "home_number" => "123"
               }
             } = json_response(conn, 200)["data"]
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

      conn = get(conn, ~p"/api/users/#{user}")
      assert conn.status == 404
    end
  end

  describe "user area" do
    test "requires authentication", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert conn.resp_body =~ "unauthenticated"
    end

    test "lists all users when authenticated", %{conn: conn} do
      user1 =
        user_fixture(%{
          cpf: "52511111112",
          name: "murilo_1",
          email: "murilo_1@hotmail.com",
          phone_number: "11979897982",
          birth_date: ~D[2004-05-06],
          password: "password_1",
          address: %{
            address: "rua elixir_1",
            cep: "09071001",
            uf: "PE",
            city: "cidade java_1",
            district: "vila programação_1",
            complement: "casa_1",
            home_number: "3214"
          }
        })

      user2 =
        user_fixture(%{
          cpf: "52511111113",
          name: "lucas",
          email: "lucas@hotmail.com",
          phone_number: "11979897983",
          birth_date: ~D[2004-05-06],
          password: "password_2",
          address: %{
            address: "rua elixir_2",
            cep: "09071003",
            uf: "PB",
            city: "cidade java_2",
            district: "vila programação_2",
            complement: "casa_2",
            home_number: "3215"
          }
        })

      conn = Guardian.Plug.sign_in(conn, user1)
      {:ok, token, _claims} = Guardian.encode_and_sign(user1)
      conn = get(conn, ~p"/api/users", %{"Authorization" => "Bearer #{token}"})

      assert json_response(conn, 200)["data"] == [
               %{
                 "cpf" => user1.cpf,
                 "email" => user1.email,
                 "id" => user1.id,
                 "name" => user1.name,
                 "phone_number" => user1.phone_number,
                 "birth_date" => to_string(user1.birth_date),
                 "address" => %{
                   "id" => user1.address.id,
                   "address" => user1.address.address,
                   "cep" => user1.address.cep,
                   "uf" => user1.address.uf,
                   "city" => user1.address.city,
                   "district" => user1.address.district,
                   "complement" => user1.address.complement,
                   "home_number" => user1.address.home_number
                 }
               },
               %{
                 "cpf" => user2.cpf,
                 "email" => user2.email,
                 "id" => user2.id,
                 "name" => user2.name,
                 "phone_number" => user2.phone_number,
                 "birth_date" => to_string(user2.birth_date),
                 "address" => %{
                   "id" => user2.address.id,
                   "address" => user2.address.address,
                   "cep" => user2.address.cep,
                   "uf" => user2.address.uf,
                   "city" => user2.address.city,
                   "district" => user2.address.district,
                   "complement" => user2.address.complement,
                   "home_number" => user2.address.home_number
                 }
               }
             ]
    end
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
