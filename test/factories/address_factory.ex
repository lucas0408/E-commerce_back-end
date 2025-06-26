defmodule BatchEcommerce.Factories.AddressFactory do
  alias BatchEcommerce.Accounts.Address

  defmacro __using__(_opts) do
    quote do
      defp random_digits_string(length) do
        Enum.map(1..length, fn _ -> Enum.random(0..9) end)
        |> Enum.join()
      end

      def address_factory do
        %Address{
          address: sequence(:address, &"rua elixir#{&1}"),
          cep:  random_digits_string(5) <> "-" <> random_digits_string(3),
          uf: "MG",
          city: sequence(:city, &"cidade java#{&1}"),
          district: sequence(:district, &"vila programação#{&1}"),
          complement: sequence(:complement, &"casa#{&1}"),
          home_number: random_digits_string(3)
        }
      end
    end
  end
end
