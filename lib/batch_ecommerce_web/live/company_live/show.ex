# lib/batch_ecommerce_web/live/company_live/show.ex
defmodule BatchEcommerceWeb.Live.CompanyLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Catalog

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    company = Accounts.get_company!(id)
    IO.inspect(company)
    top_products = get_top_5_selling_products_by_sales(company.products)

    {:ok,
     socket
     |> assign(:company, company)
     |> assign(:user, %{name: "ricardo", id: 1})
     |> assign(:top_products, top_products)}
  end

  def get_top_5_selling_products_by_sales(products) do
    products
    |> Enum.sort_by(& &1.sales_quantity, :desc)
    |> Enum.take(5)
  end




  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div class="w-full flex max-w-screen-3xl mx-auto px-6 py-4">
      <!-- Conteúdo principal à esquerda -->
      <div class="flex-1 flex flex-col h-full pl-[50px]">
        <aside class="bg-gray-100 shadow-md p-4 rounded-lg">
          <h1 class="text-4xl font-bold text-gray-800 mb-2"><%= @company.name %></h1>
          <p class="text-gray-600">CNPJ: <%= @company.cnpj %></p>
        </aside>

        <div class="flex-1 h-full overflow-auto pt-6 ">
          <%= if @active_tab == :orders do %>
            <div class="bg-gray-100 rounded-lg shadow-sm p-6 min-h-[calc(100vh-4rem)] overflow-auto ">
              <h2 class="text-2xl font-bold mb-6 text-gray-800">Últimos Pedidos</h2>

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200 border rounded-lg">
                  <thead class="bg-gray-200">
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
        </div>
      </div>

      <!-- Botões à direita -->
      <div class="flex flex-col gap-10 ml-6 pt-[130px] pl-[40px]">
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
      class={"phx-submit-loading:opacity-75 rounded-lg bg-blue-800 hover:bg-blue-700 py-3.5 px-10 shadow-lg
        hover:scale-105 transition-transform duration-300 text-base font-semibold leading-6 text-white active:text-white/80"}
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
