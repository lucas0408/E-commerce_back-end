defmodule BatchEcommerce.Factories.CompanyFactory do
  alias BatchEcommerce.Accounts.Company

  defmacro __using__(_opts) do
    quote do
      def company_factory do
        user = insert(:user)

        %Company{
          name: "Loja Arthur Santos",
          cnpj: Brcpfcnpj.cnpj_generate(),
          email: sequence(:email, &"arthursantosloja#{&1}@hotmail.com"),
          phone_number: sequence(:phone_number, &"1199999999#{&1}"),
          user_id: user.id,
          addresses: [build(:address)]
        }
      end
    end
  end
end
