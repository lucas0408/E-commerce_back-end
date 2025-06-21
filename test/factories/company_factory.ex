defmodule BatchEcommerce.Factories.CompanyFactory do
  alias BatchEcommerce.Accounts.Company

  defmacro __using__(_opts) do
    quote do
      defp random_digits_string(length) do
        Enum.map(1..length, fn _ -> Enum.random(0..9) end)
        |> Enum.join()
      end

      def company_factory do
        user = insert(:user)

        %Company{
          name: "Loja Arthur Santos",
          cnpj: random_digits_string(14),
          name: sequence(:name, &"company_test_#{&1}"),
          email: sequence(:email, &"arthursantosloja#{&1}@hotmail.com"),
          phone_number: "119#{random_digits_string(8)}",
          user_id: user.id,
          addresses: [build(:address)]
        }
      end
    end
  end
end
