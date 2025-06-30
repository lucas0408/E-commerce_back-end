defmodule BatchEcommerce.AccountsTest do
  @moduledoc """
  The Accounts context test module.
  """
  use BatchEcommerce.DataCase, async: true

  import BatchEcommerce.Factory

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.User

  describe "users" do
    test "list_users/0 returns all users" do
      inserted_users = insert_list(2, :user)
      user_list = Accounts.list_users()

      fields_to_remove = [:password]

      assert Enum.map(inserted_users, &Map.drop(&1, fields_to_remove)) ==
            Enum.map(user_list, &Map.drop(&1, fields_to_remove))
    end

    test "get_user/1 returns the user with given id" do
      user = insert(:user)
      found_user = Accounts.get_user(user.id)

      fields_to_remove = [:password]
      assert Map.drop(found_user, fields_to_remove) == Map.drop(user, fields_to_remove)
    end

    test "create_user/1 with valid data creates a user" do
      address_attrs = params_for(:address)
      valid_attrs = params_for(:user, addresses: [address_attrs])

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)

      assert user.cpf == valid_attrs.cpf
      assert user.name == valid_attrs.name
      assert user.email == valid_attrs.email
      assert user.phone_number == valid_attrs.phone_number
      assert user.birth_date == valid_attrs.birth_date
      refute is_nil(user.password_hash)

      assert Enum.count(user.addresses) == 1

      [created_address] = user.addresses

      assert created_address.address == address_attrs.address
      assert created_address.cep == address_attrs.cep
      assert created_address.uf == address_attrs.uf
      assert created_address.city == address_attrs.city
      assert created_address.district == address_attrs.district
      assert created_address.complement == address_attrs.complement
      assert created_address.home_number == address_attrs.home_number
    end

    test "create_user/1 with invalid data returns error changeset" do
      invalid_attrs = invalid_params_for(:user, [:cpf, :email, :password])

      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      update_attrs = params_for(:user)

      user = insert(:user)

      [update_address_attrs] = update_attrs.addresses

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, update_attrs)

      assert updated_user.cpf == user.cpf
      assert updated_user.name == update_attrs.name
      assert updated_user.email == update_attrs.email
      assert updated_user.phone_number == update_attrs.phone_number
      assert updated_user.birth_date == update_attrs.birth_date
      refute is_nil(updated_user.password_hash)

      assert Enum.count(updated_user.addresses) == 1

      [updated_address] = updated_user.addresses

      assert updated_address.address == update_address_attrs.address
      assert updated_address.city == update_address_attrs.city
      assert updated_address.uf == update_address_attrs.uf
      assert updated_address.city == update_address_attrs.city
      assert updated_address.district == update_address_attrs.district
      assert updated_address.complement == update_address_attrs.complement
      assert updated_address.home_number == update_address_attrs.home_number
    end

    test "update_user/2 with invalid data returns error changeset" do
      invalid_attrs = invalid_params_for(:user, [:cpf, :email, :password])
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, invalid_attrs)

      fields_to_drop = [:password]

      user_found = Accounts.get_user(user.id)

      assert Map.drop(user, fields_to_drop) ==
               Map.drop(user_found, fields_to_drop)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert Accounts.get_user(user.id) == nil
    end

    test "authenticate_user/2 with existent email and password authenticates user" do
      user = insert(:user, password: "password")

      assert {:ok, returned_user} =
               Accounts.authenticate_user(user.email, "password")

      assert returned_user.id == user.id
    end

    test "authenticate_user/2 with non-existent email or password return error" do
      invalid_email = "invalid_email@hotmail.com"
      invalid_password = "invalid_password"

      assert {:error, :invalid_credentials} =
               Accounts.authenticate_user(invalid_email, invalid_password)
    end
  end

  describe "companies" do
    setup [:create_company]

    alias BatchEcommerce.Accounts.Company

    test "get_company!/1 returns the company with given id", %{company: company} do
      assert Accounts.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = params_for(:company)

      assert {:ok, %Company{} = company} = Accounts.create_company(valid_attrs)

      assert company.name == valid_attrs.name
      assert company.cnpj == valid_attrs.cnpj
      assert company.email == valid_attrs.email
      assert company.phone_number == valid_attrs.phone_number
    end

    test "create_company/1 with invalid data returns error changeset" do
      invalid_params = invalid_params_for(:company, [:name, :cnpj, :email])
      assert {:error, %Ecto.Changeset{}} = Accounts.create_company(invalid_params)
    end

    test "update_company/2 with valid data updates the company" do
      company = insert(:company)

      update_attrs = params_for(:company)

      assert {:ok, %Company{} = company} = Accounts.update_company(company, update_attrs)
      assert company.name == update_attrs.name
      assert company.cnpj == update_attrs.cnpj
      assert company.email == update_attrs.email
      assert company.phone_number == update_attrs.phone_number
    end

    test "update_company/2 with invalid data returns error changeset", %{company: company} do
      invalid_attrs = invalid_params_for(:company, [:name, :cnpj, :email])

      assert {:error, %Ecto.Changeset{}} = Accounts.update_company(company, invalid_attrs)
      assert company == Accounts.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = insert(:company)
      assert {:ok, %Company{}} = Accounts.delete_company(company)
      assert Accounts.get_company!(company.id) == nil
    end

    test "change_company/1 returns a company changeset" do
      company = build(:company)
      assert %Ecto.Changeset{} = Accounts.change_company(company)
    end

  def create_company(_any) do
    company = insert(:company) |> Accounts.companies_preload_address()
    %{company: company}
  end
  end

  describe "notifications" do
    alias BatchEcommerce.Accounts.Notification

    import BatchEcommerce.AccountsFixtures

    @invalid_attrs %{}

    test "list_notifications/0 returns all notifications" do
      notification = notification_fixture()
      assert Accounts.list_notifications() == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Accounts.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      valid_attrs = %{}

      assert {:ok, %Notification{} = notification} = Accounts.create_notification(valid_attrs)
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      update_attrs = %{}

      assert {:ok, %Notification{} = notification} = Accounts.update_notification(notification, update_attrs)
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_notification(notification, @invalid_attrs)
      assert notification == Accounts.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Accounts.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Accounts.change_notification(notification)
    end
  end
end
