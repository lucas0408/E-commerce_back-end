defmodule BatchEcommerceWeb.UserJSON do
  alias BatchEcommerce.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  def create(%{user: user, token: token}) do
    %{data: data(user, token)}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      cpf: user.cpf,
      name: user.name,
      address_id: user.address_id,
      email: user.email,
      phone: user.phone,
      password_hash: user.password_hash
    }
  end

  defp data(%User{} = user, token) do
    %{
      id: user.id,
      cpf: user.cpf,
      name: user.name,
      address_id: user.address_id,
      email: user.email,
      phone: user.phone,
      password_hash: user.password_hash,
      token: token
    }
  end
end
