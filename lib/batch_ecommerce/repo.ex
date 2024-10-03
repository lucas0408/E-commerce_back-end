defmodule BatchEcommerce.Repo do
  use Ecto.Repo,
    otp_app: :batch_ecommerce,
    adapter: Ecto.Adapters.Postgres
end
