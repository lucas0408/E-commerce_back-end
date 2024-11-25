defmodule BatchEcommerce.Accounts.Guardian do
  @moduledoc """
  The authenticator module.
  """

  use Guardian, otp_app: :batch_ecommerce
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerce.Accounts

  def token_ttl(:access), do: {1, :hour}
  def token_ttl(:refresh), do: {7, :days}
  def token_ttl(_), do: {1, :day}

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      %User{} = user ->
        {:ok, user}

      nil ->
        {:error, :resource_not_found}
    end
  end
end
