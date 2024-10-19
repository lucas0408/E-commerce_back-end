defmodule BatchEcommerce.AccountsTest do
  use BatchEcommerce.DataCase

  alias BatchEcommerce.Accounts

  describe "users" do
    alias BatchEcommerce.Accounts.User

    import BatchEcommerce.AccountsFixtures

    @invalid_attrs %{name: nil, cpf: nil, address_id: nil, email: nil, phone: nil, password_hash: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", cpf: "some cpf", address_id: 42, email: "some email", phone: "some phone", password_hash: "some password_hash"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.cpf == "some cpf"
      assert user.address_id == 42
      assert user.email == "some email"
      assert user.phone == "some phone"
      assert user.password_hash == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", cpf: "some updated cpf", address_id: 43, email: "some updated email", phone: "some updated phone", password_hash: "some updated password_hash"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.cpf == "some updated cpf"
      assert user.address_id == 43
      assert user.email == "some updated email"
      assert user.phone == "some updated phone"
      assert user.password_hash == "some updated password_hash"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "addresses" do
    alias BatchEcommerce.Accounts.Address

    import BatchEcommerce.AccountsFixtures

    @invalid_attrs %{address: nil, cep: nil, uf: nil, city: nil, district: nil, complement: nil, home_number: nil}

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Accounts.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Accounts.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      valid_attrs = %{address: "some address", cep: "some cep", uf: "some uf", city: "some city", district: "some district", complement: "some complement", home_number: "some home_number"}

      assert {:ok, %Address{} = address} = Accounts.create_address(valid_attrs)
      assert address.address == "some address"
      assert address.cep == "some cep"
      assert address.uf == "some uf"
      assert address.city == "some city"
      assert address.district == "some district"
      assert address.complement == "some complement"
      assert address.home_number == "some home_number"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      update_attrs = %{address: "some updated address", cep: "some updated cep", uf: "some updated uf", city: "some updated city", district: "some updated district", complement: "some updated complement", home_number: "some updated home_number"}

      assert {:ok, %Address{} = address} = Accounts.update_address(address, update_attrs)
      assert address.address == "some updated address"
      assert address.cep == "some updated cep"
      assert address.uf == "some updated uf"
      assert address.city == "some updated city"
      assert address.district == "some updated district"
      assert address.complement == "some updated complement"
      assert address.home_number == "some updated home_number"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_address(address, @invalid_attrs)
      assert address == Accounts.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Accounts.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Accounts.change_address(address)
    end
  end
end
