defmodule BatchEcommerceWeb.UserControllerTest do
  @moduledoc """
  The User controller test module.
  """
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.Factory

  alias BatchEcommerce.Accounts.{User, Guardian}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_session]

    test "lists all users", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users")
      response_data = json_response(conn, 200)["data"] |> Enum.at(0)
      assert response_data["cpf"] == user.cpf
      assert response_data["name"] == user.name
      assert response_data["email"] == user.email
      assert response_data["phone_number"] == user.phone_number
      assert response_data["birth_date"] == Date.to_string(user.birth_date)
      assert length(response_data["addresses"]["data"]) == length(user.addresses)


      Enum.each(Enum.zip(response_data["addresses"]["data"], user.addresses), fn {address_response, address_params} ->
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

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: user_params = params_for(:user))
      response_data = json_response(conn, 201)["data"]

      assert response_data["cpf"] == user_params.cpf
      assert response_data["name"] == user_params.name
      assert response_data["email"] == user_params.email
      assert response_data["phone_number"] == user_params.phone_number
      assert response_data["birth_date"] == Date.to_string(user_params.birth_date)
      assert length(response_data["addresses"]["data"]) == length(user_params.addresses)

      Enum.each(Enum.zip(response_data["addresses"]["data"], user_params.addresses), fn {address_response, address_params} ->
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
      conn = post(conn, ~p"/api/users", user: invalid_params_for(:user, [:cpf, :email, :password]))
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_session]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: update_params = params_for(:user))
      response_data = json_response(conn, 200)["data"]

      assert response_data["id"] == user.id
      assert response_data["cpf"] == user.cpf
      assert response_data["name"] == update_params.name
      assert response_data["name"] != user.name
      assert response_data["email"] == update_params.email
      assert response_data["email"] != user.email
      assert response_data["phone_number"] == update_params.phone_number
      assert response_data["phone_number"] != user.phone_number
      assert response_data["birth_date"] == Date.to_string(update_params.birth_date)
      assert response_data["birth_date"] == Date.to_string(user.birth_date)

      Enum.each(Enum.zip(response_data["addresses"]["data"], update_params.addresses), fn {address_response, address_params} ->
        assert address_response["address"] == address_params.address
        assert address_response["cep"] == address_params.cep
        assert address_response["uf"] == address_params.uf
        assert address_response["city"] == address_params.city
        assert address_response["district"] == address_params.district
        assert address_response["complement"] == address_params.complement
        assert address_response["home_number"] == address_params.home_number
      end)

      Enum.each(Enum.zip(response_data["addresses"]["data"], user.addresses), fn {address_response, address_params} ->
        assert address_response["address"] != address_params.address
        assert address_response["cep"] != address_params.cep
        assert address_response["uf"] != address_params.uf
        assert address_response["city"] != address_params.city
        assert address_response["district"] != address_params.district
        assert address_response["complement"] != address_params.complement
        assert address_response["home_number"] != address_params.home_number
      end)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/users/#{user}", user: invalid_params_for(:user, [:cpf, :email, :password]))
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
      user_1 = insert(:user)

      user_2 = insert(:user)

      conn = Guardian.Plug.sign_in(conn, user_1)
      {:ok, token, _claims} = Guardian.encode_and_sign(user_1)
      conn = get(conn, ~p"/api/users", %{"Authorization" => "Bearer #{token}"})

      response_data_user1 =  json_response(conn, 200)["data"] |> Enum.at(0)

      response_data_user2 = json_response(conn, 200)["data"] |> Enum.at(1)

      assert response_data_user1["cpf"] == user_1.cpf
      assert response_data_user1["name"] == user_1.name
      assert response_data_user1["email"] == user_1.email
      assert response_data_user1["phone_number"] == user_1.phone_number
      assert response_data_user1["birth_date"] == Date.to_string(user_1.birth_date)
      assert length(response_data_user1["addresses"]["data"]) == length(user_1.addresses)

      Enum.each(Enum.zip(response_data_user1["addresses"]["data"], user_1.addresses), fn {address_response, address_params} ->
        assert address_response["address"] == address_params.address
        assert address_response["cep"] == address_params.cep
        assert address_response["uf"] == address_params.uf
        assert address_response["city"] == address_params.city
        assert address_response["district"] == address_params.district
        assert address_response["complement"] == address_params.complement
        assert address_response["home_number"] == address_params.home_number
      end)

      assert response_data_user2["cpf"] == user_2.cpf
      assert response_data_user2["name"] == user_2.name
      assert response_data_user2["email"] == user_2.email
      assert response_data_user2["phone_number"] == user_2.phone_number
      assert response_data_user2["birth_date"] == Date.to_string(user_2.birth_date)
      assert length(response_data_user2["addresses"]["data"]) == length(user_2.addresses)

      Enum.each(Enum.zip(response_data_user2["addresses"]["data"], user_2.addresses), fn {address_response, address_params} ->
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

  defp create_session(%{conn: conn}) do
    user = insert(:user)
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end
end
