# lib/batch_ecommerce_web/live/notification.ex
defmodule BatchEcommerceWeb.Live.Notification do
  use BatchEcommerceWeb, :live_component
  alias BatchEcommerce.Accounts

  def render(assigns) do
    ~H"""
    <div class="relative">
      <button
        class="relative p-2 rounded-md hover:bg-gray-100 focus:outline-none"
        phx-click="toggle-notifications"
        phx-target={@myself}
        aria-label="Notificações"
      >
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
        </svg>
        <%= if @unread_count > 0 do %>
          <span class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full">
            <%= @unread_count %>
          </span>
        <% end %>
      </button>

      <!-- Dropdown de notificações -->
      <%= if @show_notifications do %>
        <div class="absolute right-0 mt-2 w-80 bg-white rounded-md shadow-lg overflow-hidden z-50">
          <div class="py-1">
            <div class="px-4 py-2 border-b border-gray-200">
              <h3 class="text-lg font-medium text-gray-900">Notificações</h3>
            </div>
            
            <%= if Enum.empty?(@notifications) do %>
              <div class="px-4 py-3 text-sm text-gray-500">
                Nenhuma notificação nova
              </div>
            <% else %>
              <div class="max-h-96 overflow-y-auto">
                <%= for notification <- @notifications do %>
                  <div class="px-4 py-3 hover:bg-gray-50 border-b border-gray-100">
                    <div class="flex justify-between items-start">
                      <div class="flex-1">
                        <p class="text-sm font-medium text-gray-900">
                          <%= notification.title %>
                        </p>
                        <p class="text-sm text-gray-500 mt-1">
                          <%= notification.body %>
                        </p>
                      </div>
                      <span class="text-xs text-gray-400">
                        <%= format_date(notification.inserted_at) %>
                      </span>
                    </div>
                  </div>
                <% end %>
              </div>
              <div class="px-4 py-2 bg-gray-50 text-right">
                <button 
                  phx-click="mark-all-as-read" 
                  phx-target={@myself}
                  class="text-sm font-medium text-indigo-600 hover:text-indigo-500"
                >
                  Marcar todas como lidas
                </button>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, show_notifications: false, notifications: [], unread_count: 0)}
  end

  def update(%{current_company: company} = assigns, socket) do
    company_id = company && company.id

    # Busca notificações não lidas da empresa
    company_notifs = Accounts.list_unread_notifications(company_id)

    # Ordena por data
    all_notifications = 
      company_notifs
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    unread_count = Accounts.count_unread_notifications(company_id)

    {:ok, 
    socket
    |> assign(assigns)
    |> assign(notifications: all_notifications)
    |> assign(unread_count: unread_count)}
  end

  def update(%{current_user: user} = assigns, socket) do
    user_id = user && user.id


    # Busca notificações não lidas
    %{user_notifications: user_notifs} = 
      Accounts.list_unread_notifications(user_id)

    # Combina ambas as listas e ordena por data
    all_notifications = 
      (user_notifs)
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    unread_count = Accounts.count_unread_notifications(user_id)

    {:ok, 
     socket
     |> assign(assigns)
     |> assign(notifications: all_notifications)
     |> assign(unread_count: unread_count)}
  end

  def handle_event("toggle-notifications", _, socket) do
    {:noreply, assign(socket, show_notifications: !socket.assigns.show_notifications)}
  end

  def handle_event("mark-all-as-read", _, socket) do
    id =
      cond do
        socket.assigns[:current_user] && socket.assigns.current_user.id ->
          socket.assigns.current_user.id

        socket.assigns[:current_company] && socket.assigns.current_company.id ->
          socket.assigns.current_company.id

        true ->
          nil
      end

    # Marca todas como lidas
    Accounts.mark_all_as_read(id)

    {:noreply, 
     socket
     |> assign(show_notifications: false)
     |> assign(unread_count: 0)
     |> assign(notifications: [])}
  end
  
  defp format_date(naive_datetime) do
    naive_datetime
    |> NaiveDateTime.add(-3, :hour)
    |> Calendar.strftime("%d/%m/%Y às %H:%M")
  end
end