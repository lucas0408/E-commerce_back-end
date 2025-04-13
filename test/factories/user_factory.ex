defmodule BatchEcommerce.UserFactory do
  alias BatchEcommerce.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          cpf: "55555555555",
          name: "Arthur Santos",
          email: "arthursantos@hotmail.com",
          phone_number: "11999999999",
          birth_date: ~D[2004-05-06],
          password: "password",
          password_hash: "password_hash",
          addresses: [build(:address)]
        }
      end
    end
  end
end
