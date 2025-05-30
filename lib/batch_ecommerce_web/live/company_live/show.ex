# lib/batch_ecommerce_web/live/company_live/show.ex
defmodule BatchEcommerceWeb.Live.CompanyLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts

  @impl true
  def mount(%{"id" => company_id}, _session, socket) do
    company = Accounts.get_company!(company_id)
    last_5_orders = get_last_5_orders(company)

    {:ok,
     socket
     |> assign(:company, company)
     |> assign(:last_5_orders, last_5_orders)
     |> assign(:active_tab, :orders)}
  end

  defp get_last_5_orders(_company), do: [] # Você ainda pode implementar isso

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, String.to_existing_atom(tab))}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full max-w-screen-2xl mx-auto px-6 py-4">
      <div class="flex h-full">
        <aside class="w-64 h-full bg-white shadow-md p-6">
          <h1 class="text-2xl font-bold text-gray-800 mb-2"><%= @company.name %></h1>
          <p class="text-gray-600">CNPJ: <%= @company.cnpj %></p>
        </aside>

        <main class="flex-1 h-full overflow-auto p-8">
          <%= if @active_tab == :orders do %>
            <div class="bg-white rounded-lg shadow-sm p-6 min-h-[calc(100vh-4rem)] overflow-auto">
              <h2 class="text-2xl font-semibold mb-6">Últimos Pedidos</h2>

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200 border rounded-lg">
                  <thead class="bg-gray-100">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <%= for order <- @last_5_orders do %>
                      <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">#<%= order.id %></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= order.inserted_at %></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm">
                          <span class={"px-2 py-1 rounded text-xs font-medium #{status_color(order.status)}"}>
                            <%= order.status %>
                          </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">R$ <%= order.total %></td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>

                <%= if Enum.empty?(@last_5_orders) do %>
                  <div class="flex flex-col items-center justify-center h-64 mt-6">
                    <svg class="w-16 h-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                    <p class="mt-4 text-gray-500">Nenhum pedido encontrado</p>
                  </div>
                <% end %>
              </div>
            </div>
          <% else %>
            <div class="h-full flex items-center justify-center">
              <div class="text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                <h3 class="mt-2 text-lg font-medium text-gray-900">
                  <%= case @active_tab do %>
                    <% :products -> %> "Selecione 'Pedidos' para visualizar"
                    <% :edit -> %> "Selecione 'Pedidos' para visualizar"
                    <% _ -> %> "Nada para exibir"
                  <% end %>
                </h3>
              </div>
            </div>
          <% end %>
        </main>
      </div>

      <!-- Botões flutuantes -->
      <div class="absolute bottom-6 right-6 flex flex-col items-end space-y-2 z-50">
        <%= render_tab_button(:products, @active_tab == :products, "Produtos") %>
        <%= render_tab_button(:orders, @active_tab == :orders, "Pedidos") %>
        <%= render_tab_button(:edit, @active_tab == :edit, "Editar Empresa") %>
      </div>
    </div>
    """
  end

  defp render_tab_button(tab, active, label) do
    assigns = %{tab: tab, active: active, label: label}
    ~H"""
    <button
      class={"w-full text-left px-4 py-3 rounded-lg font-medium transition-colors #{if @active, do: "bg-blue-50 text-blue-600", else: "text-gray-700 hover:bg-gray-100"}"}
      phx-click="change_tab"
      phx-value-tab={@tab}
    >
      <%= @label %>
    </button>
    """
  end

  defp status_color("completed"), do: "bg-green-100 text-green-800"
  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("canceled"), do: "bg-red-100 text-red-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"
end
