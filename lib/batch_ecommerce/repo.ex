defmodule BatchEcommerce.Repo do
  use Ecto.Repo,
    otp_app: :batch_ecommerce,
    adapter: Ecto.Adapters.Postgres
  
  use Scrivener, page_size: 4

end
