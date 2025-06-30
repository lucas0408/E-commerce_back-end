defmodule BatchEcommerceWeb.Live.OrderLive.ShowUser do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.ProductReview
  alias BatchEcommerceWeb.Live.OrderLive.OrderMainContent

  @impl true
  def mount(%{"order_id" => order_id}, session, socket) do
    user_id = Map.get(session, "user_id")
    current_user = Accounts.get_user(user_id)
    order = Orders.get_order_product(order_id)

    socket =
      socket
      |> assign(order: order)
      |> assign(current_user: current_user)
      |> assign(selected_rating: 0)  # Inicia com 0 estrelas selecionadas
      |> load_review_data()


    {:ok, socket}
  end

  defp load_review_data(socket) do
    %{order: order, current_user: user, selected_rating: current_rating} = socket.assigns

    can_review = order.status == "Entregue"
    existing_review = if can_review, do: Catalog.get_review_by_user_and_product(user.id, order.product_id)

    # Se existir avaliação prévia, usa ela como rating selecionado
    selected_rating = if existing_review, do: existing_review.review, else: current_rating

    socket
    |> assign(can_review: can_review)
    |> assign(existing_review: existing_review)
    |> assign(selected_rating: selected_rating)
  end

  def handle_event("set_rating", %{"rating" => rating}, socket) do
    rating = String.to_integer(rating)
    {:noreply, assign(socket, selected_rating: rating)}
  end

  def handle_event("submit_review", _, socket) do
    %{current_user: user, order: order, selected_rating: rating, existing_review: existing_review} = socket.assigns

    review_params = %{
      "review" => rating,
      "user_id" => user.id,
      "product_id" => order.product_id
    }

    result = if existing_review do
      Catalog.update_review(existing_review, review_params)
    else
      Catalog.create_review(review_params)
    end

    case result do
      {:ok, review} ->
        socket =
          socket
          |> put_flash(:info, "Avaliação #{if existing_review, do: "atualizada", else: "salva"} com sucesso!")
          |> assign(:existing_review, review)
          |> assign(:can_review, false)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erro ao salvar avaliação")}
    end
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
    <!-- Botão Voltar -->
      <div class="mb-4 mx-[500px]">
        <.link navigate={~p"/orders"} class="inline-flex items-center text-gray-400 hover:text-gray-700">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          Voltar
        </.link>
      </div>

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
    <!-- Cabeçalho e conteúdo principal mantidos iguais -->

    <!-- Seção de avaliação (apenas para pedidos entregues) -->
    <%= if @can_review do %>
      <div class="max-w-4xl mx-auto p-6 mt-6 bg-white rounded-lg shadow">
        <h3 class="text-lg font-medium mb-4">Avalie este produto</h3>
        
        <div class="flex justify-center space-x-2 mb-4">
          <%= for star <- 1..5 do %>
            <button
              type="button"
              phx-click="set_rating"
              phx-value-rating={star}
              class={
                "text-4xl transition-colors duration-200 " <>
                if star <= @selected_rating, 
                  do: "text-yellow-400 hover:text-yellow-500", 
                  else: "text-gray-300 hover:text-gray-400"
              }
            >
              ★
            </button>
          <% end %>
        </div>

        <.button 
          phx-click="submit_review" 
          class="w-full bg-indigo-600 hover:bg-indigo-700"
        >
          Confirmar Avaliação
        </.button>
      </div>
    <% end %>

    <%= if @existing_review do %>
      <div class="max-w-4xl mx-auto p-6 mt-6 bg-white rounded-lg shadow">
        <h3 class="text-lg font-medium mb-2">Sua Avaliação</h3>
        <div class="flex justify-center">
          <%= for star <- 1..5 do %>
            <span class={"text-3xl #{if star <= @existing_review.review, do: "text-yellow-400", else: "text-gray-300"}"}>★</span>
          <% end %>
        </div>
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
