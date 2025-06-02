defmodule BatchEcommerceWeb.Live.ProductLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerceWeb.Live.ProductLive.FormComponent

  def render(assigns) do
    ~H"""
    <div class="px-4">
      <.live_component
        module={FormComponent}
        id="new-product"
        product={%Product{}}
        action={@live_action}
        patch={~p"/products"}
      >
        <h1 class="text-2xl font-bold mb-4">Creating a product</h1>
      </.live_component>

      <.back navigate={~p"/products"} class="mt-4 inline-block text-blue-600 hover:text-blue-800">
        Back to products
      </.back>
    </div>
    """
  end
end
