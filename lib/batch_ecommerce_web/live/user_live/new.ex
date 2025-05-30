defmodule BatchEcommerceWeb.Live.UserLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.Live.UserLive.FormComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :live_action, :new)}
  end

  def render(assigns) do
    ~H"""
    
    <div class="pt-20 px-4"> <!-- Adiciona padding-top para compensar o header fixo -->
      <.live_component 
        module={FormComponent} 
        id="new-user" 
        user={%User{}} 
        action={@live_action} 
        patch={~p"/users"}
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