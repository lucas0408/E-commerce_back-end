defmodule BatchEcommerceWeb.Live.ProductLive.Edit do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerce.Catalog
  alias BatchEcommerceWeb.Live.ProductLive.FormComponent
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.User

  def mount(%{"product_id" => id}, session, socket) do

    user_id = Map.get(session, "user_id")

    current_user = Accounts.get_user(user_id)

    case Accounts.user_preload_company(current_user) do
      %User{company: nil} ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/companies/new")}

      %User{company: company} ->
        product = Catalog.get_product(id)
        IO.inspect(product)
        {:ok,
        socket
        |> assign(:current_user, current_user)
        |> assign(product: product)
        |> assign(:company, company)
        |> assign(:page_title, "Nova Empresa")}
    end
  end

    def render(assigns) do
    ~H"""
        <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@current_user} id="HeaderDefault"/>
            <div class="px-4">
        <h1 class="text-3xl font-bold text-gray-900 mb-8">Criar Nova Empresa</h1>
        
        <.live_component 
          module={FormComponent} 
          id={@product.id}
          product={@product} 
          company_id={@company.id}
          action={@live_action} 
        />
        
        <.back navigate={~p"/companies"} class="mt-6 inline-block text-blue-600 hover:text-blue-800">
          ← Voltar para empresas
        </.back>  
    </div>
    """
  end
end