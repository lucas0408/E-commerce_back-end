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
end
