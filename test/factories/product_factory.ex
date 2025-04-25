defmodule BatchEcommerce.Factories.ProductFactory do
  alias BatchEcommerce.Catalog.Product

  defmacro __using__(_opts) do
    quote do
      def product_factory do

        company = insert(:company)
        category = insert(:category)
        %Product{
          name: sequence(:type, &"name_product_test_#{&1}"),
          price: 12.30,
          stock_quantity: 30,
          image_url: "http://localhost:9000/batch-bucket/#{Ecto.UUID.generate()}-product_image.jpg",
          description: "teste_descrição",
          company_id: company.id,
          categories: [category]
       }
      end
    end
  end
end
