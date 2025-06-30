# lib/batch_ecommerce_web/live/order_live/show.ex
defmodule BatchEcommerceWeb.Live.OrderLive.ShowUser do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts
  alias BatchEcommerceWeb.Live.OrderLive.OrderMainContent

  @impl true
  def mount(%{"order_id" => order_id}, session, socket) do
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
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderWithCart} user={@current_user} id="HeaderWithCart"/>
    
    <.live_component 
      module={OrderMainContent} 
      id="order-main-content" 
      order={@order} 
    />

    <%= if @order.status not in ["Entregue", "Cancelado"] do %>
      <div class="max-w-4xl mx-auto p-6 flex justify-end space-x-4">
        <.button
          phx-click="cancel_order"
          phx-value-order_product_id={@order.id}
          phx-value-order_id={@order.order_id}
          phx-value-price={@order.price}
          class="bg-red-600 hover:bg-red-700"
        >
          Cancelar Pedido
        </.button>

        <%= if @order.status == "A Caminho" do %>
          <.button
            phx-click="confirm_delivery"
            phx-value-order_id={@order.id}
            class="bg-green-600 hover:bg-green-700"
          >
            Confirmar Entrega
          </.button>
        <% end %>
      </div>
    <% end %>
    """
  end

  @impl true
  def handle_event("cancel_order", %{"order_id" => order_id, "order_product_id" => order_product_id, "price" => price}, socket) do
    order = Orders.get_order(order_id)
    order_product = Orders.update_order_product_status(order_product_id, "Cancelado", BatchEcommerce.Catalog.get_product(socket.assigns.order.product_id).company_id)
    Orders.update_order(order_id, %{
      total_price: Decimal.sub(order.total_price, price),
      status_payment: "Estornado"
    })
    
    {:noreply, assign(socket, order: order_product)}
  end

  def handle_event("confirm_delivery", %{"order_id" => order_id}, socket) do
    order = Orders.update_order_product_status(order_id, "Entregue", BatchEcommerce.Catalog.get_product(socket.assigns.order.product_id).company_id)
    {:noreply, assign(socket, order: order)}
  end
end