defmodule BatchEcommerce.UserFactory do
  alias BatchEcommerce.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        password = "password"

        %User{
          id: Ecto.UUID.generate(),
          cpf: sequence(:cpf, &"5555555555#{&1}"),
          name: "Arthur Santos",
          email: sequence(:email, &"arthursantos#{&1}@hotmail.com"),
          phone_number: sequence(:phone_number, &"1199999999#{&1}"),
          birth_date: ~D[2004-05-06],
          password: password,
          password_hash: Bcrypt.hash_pwd_salt(password),
          addresses: [build(:address)]
        }
      end
    end
  end
end
