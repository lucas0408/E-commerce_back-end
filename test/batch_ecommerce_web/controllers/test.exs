defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase
  import MyApp.AccountsFixtures
  alias MyApp.Accounts.User
  alias MyApp.Accounts.Guardian

  @create_attrs %{
    email: "some email valid",
    password: "some password_hash"
  }
  @update_attrs %{
    email: "some updated email",
    password: "some updated password_hash"
  }
  @invalid_attrs %{email: nil, password: nil}
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
    setup [:create_session]

    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]
      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some email valid"
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
               "id" => ^id,
               "email" => "some updated email"
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
      conn = delete(conn, ~p"/api/users/#{user.id}")
      assert response(conn, 204)
    end
  end

  describe "login" do
    setup [:create_user]

    test "with valid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/login", %{
          email: user.email,
          password: "some password_hash"
        })

      assert json_response(conn, 200)["data"]["id"] == user.id
    end

    test "with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, "/api/login", %{
          email: user.email,
          password: "wrong_password"
        })

      assert json_response(conn, 401)["error"] =~ "Invalid credentials"
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
          email: "some email 1",
          password: "some password_hash"
        })

      user2 =
        user_fixture(%{
          email: "some email2",
          password: "some password_hash"
        })

      conn = Guardian.Plug.sign_in(conn, user1)
      {:ok, token, _claims} = Guardian.encode_and_sign(user1)
      conn = get(conn, ~p"/api/users", %{"Authorization" => "Bearer #{token}"})

      assert json_response(conn, 200)["data"] == [
               %{"email" => user1.email, "id" => user1.id},
               %{"email" => user2.email, "id" => user2.id}
             ]
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
