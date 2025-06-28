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
    <div class="max-w-7xl rounded-lg mx-auto p-8 bg-white m-[60px]"> <!-- Adiciona padding-top para compensar o header fixo -->
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
