defmodule BatchEcommerceWeb.UserLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.Live.UserLive.FormComponent

  def render(assigns) do
    ~H"""
    <div class="px-4">
      <div class="max-w-7xl rounded-lg mx-auto p-8 bg-white m-[60px]">
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
