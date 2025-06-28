defmodule BatchEcommerceWeb.Live.CompanyLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Company
  alias BatchEcommerceWeb.Live.CompanyLive.FormComponent

  def mount(_params, session, socket) do
    # Pega o current_user da sessão
    user_id = Map.get(session, "user_id")
    current_user = Accounts.get_user(user_id)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Nova Empresa")}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@current_user} id="HeaderDefault"/>
    <div class="pt-10 px-4">
      <div class="max-w-7xl mx-auto rounded-lg bg-white">
        <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center mt-[25px] p-10">Criar Nova Empresa</h1>

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
