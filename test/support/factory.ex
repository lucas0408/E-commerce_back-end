defmodule BatchEcommerce.Factory do
  use ExMachina.Ecto, repo: BatchEcommerce.Repo
  use BatchEcommerce.Factories.UserFactory
  use BatchEcommerce.Factories.AddressFactory
  use BatchEcommerce.Factories.CompanyFactory

  def invalid_params_for(factory, fields) do
    params_for(factory)
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> if k in fields, do: {k, nil}, else: {k, v} end)
    |> Enum.into(%{})
  end
end
