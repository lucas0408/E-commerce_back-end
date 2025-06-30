defmodule BatchEcommerceWeb.UserLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.Live.UserLive.FormComponent

  def render(assigns) do
    ~H"""
    <div class="px-4">
    <!-- Botão Voltar -->
      <div class="my-4 mx-[250px]">
        <.link navigate={~p"/login"} class="inline-flex items-center text-gray-400 hover:text-gray-700">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          Voltar
        </.link>
      </div>
      <div class="rounded-lg mx-auto p-8 bg-white mb-10 mx-[250px]">
        <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center ">Criar Nova Conta</h1>
        <.live_component
          module={FormComponent}
          id="new-user"
          user={%User{}}
          action={@live_action}
          patch={~p"/products"}
        >
          <h1 class="text-2xl font-bold mb-4">Creating a user</h1>
        </.live_component>
      </div>
    </div>
    """
  end
end
