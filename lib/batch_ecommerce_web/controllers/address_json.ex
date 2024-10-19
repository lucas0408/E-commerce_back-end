defmodule BatchEcommerceWeb.AddressJSON do
  alias BatchEcommerce.Accounts.Address

  @doc """
  Renders a list of addresses.
  """
  def index(%{addresses: addresses}) do
    %{data: for(address <- addresses, do: data(address))}
  end

  @doc """
  Renders a single address.
  """
  def show(%{address: address}) do
    %{data: data(address)}
  end

  def data(%Address{} = address) do
    %{
      id: address.id,
      cep: address.cep,
      uf: address.uf,
      city: address.city,
      district: address.district,
      address: address.address,
      complement: address.complement,
      home_number: address.home_number
    }
  end
end
