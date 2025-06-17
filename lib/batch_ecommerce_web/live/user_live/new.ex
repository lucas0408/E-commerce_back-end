defmodule BatchEcommerceWeb.Live.UserLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.User
  alias BatchEcommerceWeb.Live.UserLive.FormComponent

  def render(assigns) do
    ~H"""
    <div class="px-4">
      <div class="max-w-7xl rounded-lg mx-auto bg-white m-[25px]">
        <h1 class="text-4xl font-bold text-slate-700 mb-8 text-center mt-[25px] p-10">Criar Nova Conta</h1>
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
