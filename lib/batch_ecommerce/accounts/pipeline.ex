defmodule BatchEcommerce.Accounts.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :batch_ecommerce,
    error_handler: BatchEcommerce.Accounts.ErrorHandler,
    module: BatchEcommerce.Accounts.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.LoadResource, allow_blank: true
end
