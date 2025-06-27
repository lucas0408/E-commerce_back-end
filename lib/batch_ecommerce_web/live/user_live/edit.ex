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
    <div class="pt-20 px-4"> <!-- Adiciona padding-top para compensar o header fixo -->
      <.live_component
        module={FormComponent}
        id={@user.id}
        user={@user}
        action={@live_action}
        patch={~p"/products"}
      >
        <h1 class="text-2xl font-bold mb-4">Creating a user</h1>
      </.live_component>

      <.back navigate={~p"/users"} class="mt-4 inline-block text-blue-600 hover:text-blue-800">
        Back to users
      </.back>
    </div>
    """
  end
end
