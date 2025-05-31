defmodule BatchEcommerceWeb.Live.CompanyLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.Company
  alias BatchEcommerceWeb.Live.CompanyLive.FormComponent

  def mount(_params, session, socket) do
    # Pega o current_user da sessão
    current_user = Map.get(session, "current_user")

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Nova Empresa")}
  end

  def render(assigns) do
    ~H"""
    <div class="pt-10 px-4">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center pb-10">Criar Nova Empresa</h1>

        <.live_component
          module={FormComponent}
          id="new-company"
          company={%Company{}}
          action={@live_action}
          current_user={@current_user}
          patch={~p"/companies"}
        />

        <.back navigate={~p"/companies"} class="mt-6 inline-block text-blue-600 hover:text-blue-800">
          ← Voltar para empresas
        </.back>
      </div>
    </div>
    """
  end


end
