defmodule BatchEcommerce.Factory do
  use ExMachina.Ecto, repo: BatchEcommerce.Repo
  use BatchEcommerce.UserFactory
  use BatchEcommerce.AddressFactory
end
