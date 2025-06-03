defmodule BatchEcommerceWeb.Live.HeaderLive.HeaderHelpers do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.CoreComponents

  # Atributos do componente
  attr :show_cart, :boolean, default: false
  attr :show_search, :boolean, default: false
  attr :show_menu, :boolean, default: false
  attr :notification_count, :integer, default: 0
  attr :cart_count, :integer, default: 0
  attr :user, :map, default: nil
  attr :search_query, :string, default: ""

  def render(assigns) do
    ~H"""
    <div id={"header-#{@id}"} class="sticky top-0 z-50 bg-white shadow-sm">
      <!-- Cabeçalho Principal -->
      <div class="px-3 py-3 flex items-center justify-between">
        <!-- Botão de Menu -->
        <button
          phx-click="toggle_menu"
          phx-target={@myself}
          class={"p-2 rounded-md hover:bg-gray-100 focus:outline-none #{@show_menu && "text-indigo-600"}"}
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>

        <!-- Logo ou Barra de Pesquisa -->
        <div class="flex-1 flex justify-center mx-4">
            <%= if @show_search do %>
              <.search_bar query={@search_query} target="#product-live-view" />
            <% else %>
            <a href="/" class="text-xl font-bold text-gray-800">
              <span class="text-indigo-600">Batch</span>Ecommerce
            </a>
          <% end %>
        </div>

        <!-- Área de Ícones -->
        <div class="flex justify-end items-center space-x-4">

          <%= if @user do %>
            <.notification_badge count={@notification_count} click_event="show_notifications" />

            <%= if @show_cart do %>
              <.cart_icon count={@cart_count} />
            <% end %>
            <.user_profile name={@user.name} id={@user.id} avatar={"/images/default-avatar.png"} />
          <% else %>
            <div class="flex space-x-2">
            <.link
              navigate={~p"/login"}
              class="text-sm font-medium text-indigo-600 hover:text-indigo-500 hover:underline"
            >
              Faça login ou cadastre-se
            </.link>
            </div>
          <% end %>
        </div>
      </div>

      <!-- Menu Lateral -->
      <.header_side_menu :if={@show_menu} user={@user} myself={@myself} />
    </div>
    """
  end

  def handle_event("toggle_menu", _event, socket) do
    {:noreply, assign(socket, show_menu: !socket.assigns.show_menu)}
  end
end
