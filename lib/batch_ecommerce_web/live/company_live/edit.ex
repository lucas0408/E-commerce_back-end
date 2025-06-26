defmodule BatchEcommerceWeb.Live.CompanyLive.Edit do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.Company
  alias BatchEcommerce.Accounts
  alias BatchEcommerceWeb.Live.CompanyLive.FormComponent
  alias BatchEcommerceWeb.Live.HeaderLive.HeaderDefault

  def mount(%{"id" => id}, session, socket) do
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)
    company = Accounts.get_company!(id)
    {:ok, assign(socket, company: company, user: current_user)}
  end

    def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} id="HeaderDefault"/>
    <div class="pt-10 px-4">
      <div class="max-w-7xl mx-auto rounded-lg bg-white">
        <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center mt-[25px] p-10">Criar Nova Empresa</h1>

        <.live_component
          module={FormComponent}
          id={@company.id}
          company={@company}
          action={@live_action}
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
