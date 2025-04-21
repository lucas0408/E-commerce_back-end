defmodule BatchEcommerce.Factory do
  use ExMachina.Ecto, repo: BatchEcommerce.Repo
  use BatchEcommerce.Factories.UserFactory
  use BatchEcommerce.Factories.AddressFactory
  use BatchEcommerce.Factories.CompanyFactory
  use BatchEcommerce.Factories.CategoryFactory
  use BatchEcommerce.Factories.ProductFactory
  use BatchEcommerce.Factories.UserFactory
  use BatchEcommerce.Factories.CartProductFactory
  use BatchEcommerce.Factories.OrderFactory

  def invalid_params_for(factory, fields) do
    params_for(factory)
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> if k in fields, do: {k, nil}, else: {k, v} end)
    |> Enum.into(%{})
  end

end
