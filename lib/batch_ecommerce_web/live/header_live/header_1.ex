defmodule BatchEcommerceWeb.Live.HeaderLive.Header1 do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.CoreComponents

  @impl true
  def mount(socket) do
    {:ok, assign(socket, show_menu: false)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign_new(:menu_click_event, fn -> "toggle_menu" end)
      |> assign(assigns)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_menu", _params, socket) do
    {:noreply, update(socket, :show_menu, fn show -> not show end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <header class="sticky top-0 z-50 bg-white shadow-sm">
      <div class="container mx-auto px-4 py-3 flex items-center justify-between">
        <!-- Botão do menu - usando phx-click e phx-target diretamente -->
        <button 
          phx-click="toggle_menu"
          phx-target={@myself}
          class="p-2 rounded-md hover:bg-gray-100 focus:outline-none"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
               viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <!-- Logo centralizada -->
        <div class="flex-1 flex justify-center">
          <a href="/" class="text-xl font-bold text-gray-800">
            <span class="text-indigo-600">Batch</span>Ecommerce
          </a>  
        </div>

        <!-- Login e Cadastro -->
        <div class="flex space-x-2">
          <a href="/login" class="p-2 rounded-md hover:bg-gray-100 focus:outline-none">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
                 viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1" />
            </svg>
          </a>
          <a href="/users/new" class="p-2 rounded-md hover:bg-gray-100 focus:outline-none">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
                 viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                    d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
            </svg>
          </a>
        </div>
      </div>

      <!-- Exibe o menu lateral simples se show_menu for true -->
      <%= if @show_menu do %>
        <.simple_sidebar_menu myself={@myself} />
      <% end %>
    </header>
    """
  end
end