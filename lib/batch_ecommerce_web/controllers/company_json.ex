defmodule BatchEcommerceWeb.CompanyJSON do
  alias BatchEcommerce.Accounts.Company
  alias BatchEcommerceWeb.AddressJSON

  @doc """
  Renders a list of companies.
  """
  def index(%{companies: companies}) do
    %{data: for(company <- companies, do: data(company))}
  end

  @doc """
  Renders a single company.
  """
  def show(%{company: company}) do
    %{data: data(company)}
  end

  defp data(%Company{} = company) do
    %{
      id: company.id,
      cnpj: company.cnpj,
      name: company.name,
      email: company.email,
      phone_number: company.phone_number,
      address: AddressJSON.data(company.address)
    }
  end
end
