# lib/batch_ecommerce_web/live/order_live/order_main_content.ex
defmodule BatchEcommerceWeb.Live.OrderLive.OrderMainContent do
  use BatchEcommerceWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <.header>
        Acompanhamento do Pedido #<%= @order.id %>
      </.header>

      <!-- Status Timeline -->
      <div class="flex justify-between items-center my-8">
        <%= for {status, idx} <- Enum.with_index(["Preparando Pedido", "Enviado", "A Caminho", "Entregue"]) do %>
          <div class="flex flex-col items-center">
            <div class={"w-16 h-16 rounded-full flex items-center justify-center #{if status_active?(@order.status, idx), do: "bg-green-100 border-2 border-green-500", else: "bg-gray-100 border-2 border-gray-300"}"}>
              <.icon name={get_status_icon(status)} class={"w-8 h-8 #{if status_active?(@order.status, idx), do: "text-green-600", else: "text-gray-400"}"} />
            </div>
            <span class={"mt-2 text-sm font-medium #{if status_active?(@order.status, idx), do: "text-green-600", else: "text-gray-500"}"}>
              <%= status %>
            </span>
          </div>
        <% end %>
      </div>

      <!-- Order Details -->
      <div class="bg-white rounded-lg shadow p-6 mb-6">
        <.header>
          Detalhes do Pedido
        </.header>

        <div class="grid grid-cols-2 gap-4 mt-4">
          <div>
            <p class="text-sm text-gray-500">Número do Pedido</p>
            <p class="font-medium"><%= @order.id %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Data</p>
            <p class="font-medium"><%= format_date(@order.inserted_at) %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Quantidade</p>
            <p class="font-medium"><%= @order.quantity %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Valor Total</p>
            <p class="font-medium">R$ <%= Decimal.round(@order.price, 2) %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Status Atual</p>
            <p class="font-medium"><%= @order.status %></p>
          </div>
        </div>

        <%= if @order.status == "Cancelado" do %>
          <div class="mt-4 p-4 bg-red-100 text-red-700 rounded-lg">
            Pedido cancelado. Entre em contato com o suporte se precisar de ajuda.
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp status_active?(current_status, index) do
    status_order = ["Preparando Pedido", "Enviado", "A Caminho", "Entregue"]
    current_index = Enum.find_index(status_order, &(&1 == current_status))
    current_index && index <= current_index
  end

  defp get_status_icon(status) do
    case status do
      "Preparando Pedido" -> "hero-clipboard-document-list"
      "Enviado" -> "hero-truck"
      "A Caminho" -> "hero-map"
      "Entregue" -> "hero-check-circle"
      _ -> "hero-question-mark-circle"
    end
  end

  defp format_date(datetime) do
    datetime
    |> DateTime.add(-3, :hour)
    |> Calendar.strftime("%d/%m/%Y às %H:%M")
  end
end