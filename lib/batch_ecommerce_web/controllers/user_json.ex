defmodule BatchEcommerceWeb.UserJSON do
  alias BatchEcommerce.Accounts.{User, Address}
  alias BatchEcommerce.Repo
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
    IO.inspect(user)
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      cpf: user.cpf,
      phone: user.phone,
      address: %{
        address_id: user.address_id,
        address: user.address.address,
        cep: user.address.cep,
        city: user.address.city,
        complement: user.address.complement,
        district: user.address.district,
        home_number: user.address.home_number,
        uf: user.address.uf
      }
    }
  end

  defp data(%User{} = user, token) do
    IO.inspect(user)
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      cpf: user.cpf,
      phone: user.phone,
      token: token,
      address: %{
        address_id: user.address_id,
        address: user.address.address,
        cep: user.address.cep,
        city: user.address.city,
        complement: user.address.complement,
        district: user.address.district,
        home_number: user.address.home_number,
        uf: user.address.uf
      }
    }
  end
end
