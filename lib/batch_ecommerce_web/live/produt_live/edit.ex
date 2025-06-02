defmodule BatchEcommerceWeb.Live.ProductLive.Edit do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog
  alias BatchEcommerceWeb.Live.ProductLive.FormComponent

  def mount(%{"product_id" => id}, _session, socket) do
    product = Catalog.get_product(id)
    {:ok, assign(socket, product: product)}
  end

    def render(assigns) do
    ~H"""
    <div class="pt-20 px-4">
      <div class="max-w-2xl mx-auto">
        <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@current_user} id="HeaderDefault"/>
        <h1 class="text-3xl font-bold text-gray-900 mb-8">Criar Nova Empresa</h1>
        
        <.live_component 
          module={FormComponent} 
          id={@product.id}
          product={@product} 
          action={@live_action} 
        />
        
        <.back navigate={~p"/companies"} class="mt-6 inline-block text-blue-600 hover:text-blue-800">
          ← Voltar para empresas
        </.back>
      </div>
    </div>
    """
  end
end