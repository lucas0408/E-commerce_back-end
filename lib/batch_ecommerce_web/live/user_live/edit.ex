defmodule BatchEcommerceWeb.Live.UserLive.Edit do
  use BatchEcommerceWeb, :live_view

  alias BatchEcommerce.Accounts
  alias BatchEcommerceWeb.Live.UserLive.FormComponent

  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user(id)
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderWithCart} id="HeaderWithCart"/>
     <!-- Botão Voltar -->
      <div class="mb-4 ml-[290px] mt-10">
        <.back_link
          to={~p"/users/#{@user.id}"}
          text="Voltar"
          class="ml-4 inline-flex items-center text-gray-400 hover:text-gray-700"
          icon_class="h-6 w-6 mr-2 text-gray-400 hover:text-gray-700"
        />
      </div>
    <div class="max-w-7xl rounded-lg mx-auto p-8 bg-white mb-10">
      <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center ">Alterar Informações da Conta</h1>
      <.live_component
        module={FormComponent}
        id={@user.id}
        user={@user}
        action={@live_action}
        patch={~p"/products"}
      >
        <h1 class="text-2xl font-bold mb-4">Creating a user</h1>
      </.live_component>
    </div>
    """
  end
end
