defmodule BatchEcommerceWeb.Live.OrderLive.ShowCompany do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts
  alias BatchEcommerceWeb.Live.OrderLive.OrderMainContent

  @impl true
  def mount(%{"order_id" => order_id}, session, socket) do
    IO.inspect(socket)
    user_id = Map.get(session, "user_id")
    current_user = Accounts.get_user(user_id)

    order =
      order_id
      |> Orders.get_order_product()

    socket =
      socket
      |> assign(order: order)
      |> assign(:current_user, current_user)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@current_user} company={@current_company} id="HeaderDefault"/>

    <.live_component
      module={OrderMainContent}
      id="order-main-content"
      order={@order}
    />

    <!-- Botões específicos para a visão da empresa -->
    <%= if @order.status not in ["Entregue", "Cancelado"] do %>
      <div class="max-w-4xl mx-auto p-6 flex justify-end space-x-4">
        <!-- Botão de Cancelar com Estorno -->
        <.button
          phx-click="cancel_and_refund"
          phx-value-order_product_id={@order.id}
          phx-value-order_id={@order.order_id}
          phx-value-price={@order.price}
          class="bg-red-600 hover:bg-red-700"
        >
          Cancelar e Estornar
        </.button>

        <!-- Botão para Avançar Status -->
        <.button
          phx-click="advance_status"
          phx-value-order_id={@order.id}
          phx-value-current_status={@order.status}
          class="bg-blue-600 hover:bg-blue-700"
        >
          Avançar Etapa
        </.button>
      </div>
    <% end %>
    """
  end

  #review
  @impl true
  def handle_event("cancel_and_refund", %{"order_id" => _order_id, "order_product_id" => order_product_id, "price" => _price}, socket) do
    # Lógica para cancelar e fazer estorno
    #order = Orders.get_order(order_id) REVIEW
    order_product = Orders.update_order_product_status(order_product_id, "Cancelado", socket.assigns.current_company.id)

    {:noreply, assign(socket, order: order_product)}
  end

  def handle_event("advance_status", %{"order_id" => order_id, "current_status" => current_status}, socket) do
    # Lógica para avançar para o próximo status
    new_status = case current_status do
      "Preparando Pedido" -> "Enviado"
      "Enviado" -> "A Caminho"
      "A Caminho" -> "Entregue"
      _ -> current_status
    end

    order = Orders.update_order_product_status(order_id, new_status, Orders.get_order(socket.assigns.order.order_id).user_id)
    {:noreply, assign(socket, order: order)}

    if(new_status == "Enviado") do
      Orders.update_order(order_id, %{status_payment: "Aceito"})
    end
  end
end
