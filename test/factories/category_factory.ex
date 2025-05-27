defmodule BatchEcommerce.Factories.CategoryFactory do
  alias BatchEcommerce.Catalog.Category

  defmacro __using__(_opts) do
    quote do
      def category_factory do

        %Category{
          type: sequence(:type, &"type_category_test_#{&1}")
        }
      end
    end
  end
end