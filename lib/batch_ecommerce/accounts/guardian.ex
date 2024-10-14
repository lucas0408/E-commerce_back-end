defmodule BatchEcommerce.Accounts.Guardian do
  use Guardian, otp_app: :batch_ecommerce
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerce.Accounts

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :not_found}
    end
  end
end
