# lib/batch_ecommerce_web/live/company_live/show_content.ex
defmodule BatchEcommerceWeb.Live.CompanyLive.ShowContent do
  use BatchEcommerceWeb, :live_component

  def render(assigns) do
    ~H"""
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
        </div>
    </div>
    """
  end


  defp status_color("completed"), do: "bg-green-100 text-green-800"
  defp status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_color("canceled"), do: "bg-red-100 text-red-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"
end
