defmodule BatchEcommerce.AddressFactory do
  alias BatchEcommerce.Accounts.Address

  defmacro __using__(_opts) do
    quote do
      def address_factory do
        %Address{
          address: "rua elixir",
          cep: "09071000",
          uf: "SP",
          city: "cidade java",
          district: "vila programação",
          complement: "casa",
          home_number: "321"
        }
      end
    end
  end
end
