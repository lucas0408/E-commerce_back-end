defmodule BatchEcommerceWeb.Live.OrderLive.Index do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts


  @impl true
  def mount(_params, session, socket) do
    # 1) Pega o user_id da sessão
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)

    # 2) Busca todos os pedidos desse usuário, já pré-carregando os order_products e cada produto
    orders =
      user_id
      |> Orders.list_orders_by_user() 
      # (essa função deve devolver uma lista de %Order{} com :order_products e cada :product pré-carregados)

    # 3) Guarda no assign
    socket = 
      socket
      |> assign(orders: orders)
      |> assign(:current_user, current_user)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderWithCart} user={@current_user} id="HeaderWithCart"/>
    <div>
      <h1 class="text-2xl font-bold mb-4">Meus Pedidos</h1>

      <table class="min-w-full border-collapse">
        <thead>
          <tr class="bg-gray-100">
            <th class="px-4 py-2 text-left">Imagem</th>
            <th class="px-4 py-2 text-left">Nome do Produto</th>
            <th class="px-4 py-2 text-left">Status de Pagamento</th>
            <th class="px-4 py-2 text-left">Status de Entrega</th>
            <th class="px-4 py-2 text-left">Ações</th>
          </tr>
        </thead>
        <tbody>
          <%= for order <- @orders do %>
            <%= for op <- order.order_products do %>
              <tr class="border-t">
                <!-- Coluna 1: imagem do produto -->
                <td class="px-4 py-2">
                  <img src={op.product.image_url} 
                       alt={op.product.name} 
                       class="w-16 h-16 object-cover rounded" />
                </td>

                <!-- Coluna 2: nome do produto -->
                <td class="px-4 py-2">
                  <%= op.product.name %>
                </td>

                <!-- Coluna 3: status de pagamento (fixo: Pendente) -->
                <td class="px-4 py-2 text-yellow-600 font-medium">
                  <%= order.status_payment %>
                </td>

                <!-- Coluna 4: status de entrega (fixo: Preparando Pedido) -->
                <td class="px-4 py-2 text-blue-600 font-medium">
                  <%= op.status %>
                </td>

                <!-- Coluna 5: botão “Ver Mais” que leva para /order/:order_id -->
                <td class="px-4 py-2">
                  <.link patch={~p"/orders/#{op.id}"}>
                    <button>Ver mais</button>
                  </.link>
                </td>
              </tr>
            <% end %>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
