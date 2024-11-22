defmodule BatchEcommerce.AccountsFixtures do
  alias BatchEcommerce.Repo
  alias BatchEcommerce.{Accounts, ShoppingCart}

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
        cpf: "52511111111",
        name: "murilo",
        email: "murilo@hotmail.com",
        phone_number: "11979897989",
        birth_date: ~D[2004-05-06],
        password: "password",
        password_hash: "password_hash",
        address: %{
          address: "rua elixir",
          cep: "09071000",
          uf: "SP",
          city: "cidade java",
          district: "vila programação",
          complement: "casa",
          home_number: "321"
        }
      })
      |> Accounts.create_user()
       ShoppingCart.create_cart(%{user_id: user.id})

    Repo.preload(user, :address)
  end

  @doc """
  Generate a company.
  """
  def company_fixture(user_id \\ user_fixture().id, attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> Enum.into(%{
        cnpj: "11111111111111",
        email: "murilo@hotmail.com",
        name: "some name",
        phone_number: "11979897989",
        user_id: user_id,
        address: %{
          address: "rua elixir",
          cep: "09071000",
          uf: "SP",
          city: "cidade java",
          district: "vila programação",
          complement: "casa",
          home_number: "321"
        }
      })
      |> BatchEcommerce.Accounts.create_company()

    company
  end
end
