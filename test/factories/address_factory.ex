defmodule BatchEcommerce.Factories.AddressFactory do
  alias BatchEcommerce.Accounts.Address

  defmacro __using__(_opts) do
    quote do
      defp random_digits_string(length) do
        Enum.map(1..length, fn _ -> Enum.random(0..9) end)
        |> Enum.join()
      end

      defp random_letters_string(length) do
        letters = Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z)
        Enum.map(1..length, fn _ -> Enum.random(letters) end)
        |> to_string()
      end

      def address_factory do
        %Address{
          address: sequence(:address, &"rua elixir#{&1}"),
          cep:  random_digits_string(8),
          uf: random_letters_string(2),
          city: sequence(:city, &"cidade java#{&1}"),
          district: sequence(:district, &"vila programação#{&1}"),
          complement: sequence(:complement, &"casa#{&1}"),
          home_number: random_digits_string(3)
        }
      end
    end
  end
end
