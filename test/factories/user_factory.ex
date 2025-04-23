defmodule BatchEcommerce.Factories.UserFactory do
  alias BatchEcommerce.Accounts.User

  defmacro __using__(_opts) do
    quote do
      defp random_digits_string(length) do
        Enum.map(1..length, fn _ -> Enum.random(0..9) end)
        |> Enum.join()
      end

      def user_factory do
        password = "password"

        %User{
          id: Ecto.UUID.generate(),
          cpf: random_digits_string(11),
          name: "Arthur Santos",
          email: sequence(:email, &"arthursantos#{&1}@hotmail.com"),
          phone_number: "119#{random_digits_string(8)}",
          birth_date: ~D[2004-05-06],
          password: password,
          password_hash: Bcrypt.hash_pwd_salt(password),
          addresses: [build(:address)]
        }
      end
    end
  end
end
