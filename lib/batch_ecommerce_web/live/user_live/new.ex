defmodule BatchEcommerceWeb.Live.UserLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.Live.UserLive.FormComponent


  def render(assigns) do
    ~H"""
    <div class="px-4">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">Criar Nova Conta</h1>
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
    </div>
    """
  end
end
