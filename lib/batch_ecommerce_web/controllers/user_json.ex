defmodule BatchEcommerceWeb.UserJSON do
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.AddressJSON

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
      name: user.name,
      email: user.email,
      cpf: user.cpf,
      phone_number: user.phone_number,
      birth_date: user.birth_date,
      address: AddressJSON.data(user.address)
    }
  end

  defp data(%User{} = user, token) do
    Map.put(data(user), :token, token)
  end
end
