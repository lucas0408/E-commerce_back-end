defmodule BatchEcommerceWeb.UserControllerTest do
  @moduledoc """
  The User controller test module.
  """
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
    cpf: "52511111111",
    name: "murilo updated",
    email: "murilo@hotmail.com",
    phone_number: "11979897989",
    birth_date: "2005-05-06",
    addresses: [
      %{
        address: "rua python",
        cep: "09071001",
        uf: "MG",
        city: "cidade ruby",
        district: "vila destruição",
        complement: "apartamento",
        home_number: "123"
      }
    ]
  }

  @invalid_attrs %{
    cpf: nil,
    name: nil,
    email: nil,
    phone_number: nil,
    birth_date: nil,
    password: nil,
    addresses: [nil]
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

      user = BatchEcommerce.Accounts.get_user(id)

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["cpf"] == "52511111111"
      assert response_data["name"] == "murilo"
      assert response_data["email"] == "murilo@hotmail.com"
      assert response_data["phone_number"] == "11979897989"
      assert response_data["birth_date"] == "2004-05-06"
      assert length(response_data["addresses"]["data"]) == length(user.addresses)

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

      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == id
      assert response_data["cpf"] == "52511111111"
      assert response_data["name"] == "murilo updated"
      assert response_data["email"] == "murilo@hotmail.com"
      assert response_data["phone_number"] == "11979897989"
      assert response_data["birth_date"] == "2005-05-06"
      assert length(response_data["addresses"]["data"]) == length(user.addresses)

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
      assert conn.status == 400
    end
  end

  describe "user area" do
    test "requires authentication", %{conn: conn} do
      conn = get(conn, ~p"/api/users")
      assert conn.resp_body =~ "unauthenticated"
    end

    test "lists all users when authenticated", %{conn: conn} do
      user_1 =
        user_fixture(%{
          cpf: "52511111112",
          name: "murilo_1",
          email: "murilo_1@hotmail.com",
          phone_number: "11979897982",
          birth_date: "2004-05-06",
          password: "password_1",
          addresses: [
            %{
              address: "rua elixir_1",
              cep: "09071001",
              uf: "PE",
              city: "cidade java_1",
              district: "vila programação_1",
              complement: "casa_1",
              home_number: "3214"
            }
          ]
        })

      user_2 =
        user_fixture(%{
          cpf: "52511111113",
          name: "lucas",
          email: "lucas@hotmail.com",
          phone_number: "11979897983",
          birth_date: "2004-05-06",
          password: "password_2",
          addresses: [
            %{
              address: "rua elixir_2",
              cep: "09071003",
              uf: "PB",
              city: "cidade java_2",
              district: "vila programação_2",
              complement: "casa_2",
              home_number: "3215"
            }
          ]
        })

      conn = Guardian.Plug.sign_in(conn, user_1)
      {:ok, token, _claims} = Guardian.encode_and_sign(user_1)
      conn = get(conn, ~p"/api/users", %{"Authorization" => "Bearer #{token}"})

      assert json_response(conn, 200)["data"] |> Enum.at(0) |> Map.get("id") == user_1.id

      assert json_response(conn, 200)["data"] |> Enum.at(1) |> Map.get("id") == user_2.id

      # TODO found a better way to do this test in future
      # assert response_data_2["id"] == user_1.id
      # assert response_data_2["cpf"] == "52511111113"
      # assert response_data_2["name"] == "lucas"
      # assert response_data_2["email"] == "lucas@hotmail.com"
      # assert response_data_2["phone_number"] == "11979897983"
      # assert response_data_2["birth_date"] == "2004-05-06"
      # assert response_data_2["password"] == "password_2"
      # assert length(response_data_2["addresses"]["data"]) == length(user_2.addresses)

      # Enum.each(response_data_2["addresses"]["data"], fn address ->
      #   assert Map.has_key?(address, "address")
      #   assert Map.has_key?(address, "cep")
      #   assert Map.has_key?(address, "uf")
      #   assert Map.has_key?(address, "city")
      #   assert Map.has_key?(address, "district")
      #   assert Map.has_key?(address, "complement")
      #   assert Map.has_key?(address, "home_number")
      # end)
    end
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
