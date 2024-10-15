defmodule BatchEcommerce.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BatchEcommerce.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        address_id: 42,
        cpf: "some cpf",
        email: "some email",
        name: "some name",
        password_hash: "some password_hash",
        phone: "some phone"
      })
      |> BatchEcommerce.Accounts.create_user()

    user
  end

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    {:ok, address} =
      attrs
      |> Enum.into(%{
        address: "some address",
        cep: "some cep",
        city: "some city",
        complement: "some complement",
        district: "some district",
        home_number: "some home_number",
        uf: "some uf"
      })
      |> BatchEcommerce.Accounts.create_address()

    address
  end
end
