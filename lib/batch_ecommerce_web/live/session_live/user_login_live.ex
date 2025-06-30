defmodule BatchEcommerceWeb.UserLoginLive do

  use BatchEcommerceWeb, :live_view

  def render(assigns) do
    ~H"""
       <.live_component
        module={BatchEcommerceWeb.Live.HeaderLive.HeaderBase}
        id="header-base"
        />

    <div class="mx-auto max-w-sm b-red-500 mt-[80px]">
      <.header class="text-center">

        Acesse a conta
        <:subtitle>
          Não tem uma conta?
          <.link navigate={~p"/register"} class="font-semibold text-brand hover:text-indigo-800 text-indigo-500">
            Registre-se
          </.link>
          e crie uma conta agora.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/login"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Senha" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Manter-me logado" />
          <.link href={~p"/users/reset_password"} class="text-sm text-gray-500 hover:text-gray-800 font-semibold">
            Esqueceu a senha?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full bg-indigo-600 hover:bg-indigo-800">
            Entrar<span aria-hidden="true"></span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
