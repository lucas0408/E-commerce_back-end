defmodule BatchEcommerceWeb.Live.CompanyLive.Edit do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  alias BatchEcommerceWeb.Live.CompanyLive.FormComponent

  def mount(%{"id" => id}, session, socket) do
    user_id = Map.get(session, "user_id")
    current_user = Accounts.get_user(user_id)
    company = Accounts.get_company!(id)
    {:ok, assign(socket, company: company, user: current_user)}
  end

    def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} company={@current_company} id="HeaderDefault"/>
    <div class="pt-10 px-4 mb-20">
    <!-- Botão Voltar -->
      <div class="mb-4 ml-[275px]">
        <.link navigate={~p"/companies"} class="inline-flex items-center text-gray-400 hover:text-gray-700">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          Voltar
        </.link>
      </div>
      <div class="max-w-7xl mx-auto rounded-lg bg-white p-8">
        <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center ">Criar Nova Empresa</h1>

        <.live_component
          module={FormComponent}
          id={@company.id}
          company={@company}
          action={@live_action}
          patch={~p"/companies"}
        />
      </div>
    </div>
    """
  end
end
