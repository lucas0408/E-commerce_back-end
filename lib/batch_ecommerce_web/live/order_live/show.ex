defmodule BatchEcommerceWeb.Live.OrderLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts

  @impl true
  def mount(%{"order_id" => order_id}, session, socket) do
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)

    order =
      order_id
      |> Orders.get_order_product()

    IO.inspect(order)
    
    socket = 
      socket
      |> assign(order: order)
      |> assign(:current_user, current_user)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderWithCart} user={@current_user} id="HeaderWithCart"/>
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
            <p class="font-medium">R$   <%= Decimal.round(@order.price, 2) %></p>
          </div>
          <div>
            <p class="text-sm text-gray-500">Status Atual</p>
            <p class="font-medium"><%= @order.status %></p>
          </div>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="flex justify-end space-x-4">
        <.button
          phx-click="cancel_order"
          phx-value-order_product_id={@order.id}
          phx-value-order_id={@order.order_id}
          phx-value-price={@order.price}
          class="bg-red-600 hover:bg-red-700"
        >
          Cancelar Pedido
        </.button>
        <.button
          phx-click="confirm_delivery"
          phx-value-order_id={@order.id}
          class="bg-green-600 hover:bg-green-700"
          disabled={@order.status != "A Caminho"}
        >
          Confirmar Entrega
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("cancel_order", %{"order_id" => order_id, "order_product_id" => order_product_id, "price" => price}, socket) do
    order = Orders.get_order(order_id)
    Orders.update_order_product_status(order_product_id, "Cancelado")
    Orders.update_order(order_id, %{
      total_price: Decimal.sub(order.total_price, price),
      status_payment: "Estornado"
    })
    
    {:noreply, socket}
  end

  def handle_event("confirm_delivery", %{"order_id" => order_id}, socket) do
    Orders.update_order_product_status(order_id, "Entregue")
    {:noreply, socket}
  end

  def format_date(datetime) do
    datetime
    |> DateTime.add(-3, :hour)
    |> Calendar.strftime("%d/%m/%Y às %H:%M")
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
end