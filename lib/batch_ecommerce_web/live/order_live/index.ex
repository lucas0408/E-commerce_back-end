defmodule BatchEcommerceWeb.Live.OrderLive.Index do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts


  @impl true
  def mount(_params, session, socket) do
    # 1) Pega o user_id da sessão
    user_id = Map.get(session, "user_id")
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
    <div class="p-10">
      <div class="mb-2 bg-white p-3 rounded-t-lg">
        <h1 class="text-3xl text-gray-900 font-bold text-center">Meus Pedidos</h1>
      </div>

      <table class="min-w-full border-collapse bg-white rounded-b-lg">
        <thead>
          <tr class="text-gray-600">
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
                  <img src={op.product.filename}
                      alt={op.product.name}
                      class="w-16 h-16 object-cover rounded" />
                </td>

                <!-- Coluna 2: nome do produto -->
                <td class="px-4 py-2">
                  <%= op.product.name %>
                </td>

                <!-- Coluna 3: status de pagamento com cor dinâmica -->
                <td class="px-4 py-2">
                  <span class={
                    "px-2 py-1 rounded-full text-xs font-semibold " <>
                    case order.status_payment do
                      "confirmado" -> "bg-green-100 text-green-700"
                      "pendente" -> "bg-yellow-100 text-amber-700"
                      "Peendente" -> "bg-yellow-100 text-amber-700"
                      _ -> "bg-gray-100 text-gray-600"
                    end
                  }>
                    <%= order.status_payment %>
                  </span>
                </td>

                <!-- Coluna 4: status de entrega com cor dinâmica -->
                <td class="px-4 py-2">
                  <span class={
                    "px-2 py-1 rounded-full text-xs font-semibold " <>
                    case op.status do
                      "Entregue" -> "bg-green-100 text-green-700"
                      "Preparando Pedido" -> "bg-indigo-100 text-gray-500"
                      "A Caminho" -> "bg-yellow-100 text-amber-700"
                      _ -> "bg-gray-100 text-gray-600"
                    end
                  }>
                    <%= op.status %>
                  </span>
                </td>

                <!-- Coluna 5: botão “Ver Mais” -->
                <td class="px-4 py-2 text-blue-600">
                  <.link patch={~p"/orders/#{op.id}"}>
                    <button class="text-sm text-blue-600 hover:underline font-medium hover:text-blue-900">Ver mais</button>
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
