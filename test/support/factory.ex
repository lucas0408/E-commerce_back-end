defmodule BatchEcommerce.Factory do
  use ExMachina.Ecto, repo: BatchEcommerce.Repo
  use BatchEcommerce.Factories.UserFactory
  #use BatchEcommerce.Factories.AddressFactory
  #use BatchEcommerce.Factories.CompanyFactory
  use BatchEcommerce.Factories.CategoryFactory
  use BatchEcommerce.Factories.ProductFactory
  #use BatchEcommerce.Factories.UserFactory
  use BatchEcommerce.Factories.CartProductFactory
  use BatchEcommerce.Factories.OrderFactory

  def invalid_params_for(factory, fields) when factory == :product do
    params_for_product()
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> if k in fields, do: {k, nil}, else: {k, v} end)
    |> Enum.into(%{})
  end

  def invalid_params_for(factory, fields) do
    params_for(factory)
    |> Enum.into(%{})
    |> Enum.map(fn {k, v} -> if k in fields, do: {k, nil}, else: {k, v} end)
    |> Enum.into(%{})
  end

  def params_for_product do
    category_ids = Enum.map(insert_list(2, :category), fn category -> category.id end)
    attrs_product = params_for(:product)
    %{attrs_product | categories: category_ids}
  end

end
