defmodule BatchEcommerceWeb.Live.ShoppingCart.Index do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.ShoppingCart

  def mount(_params, session, socket) do
    current_user = Map.get(session, "current_user")
    
    # Busca os produtos do carrinho e precarrega as associações necessárias
    cart_products = 
      current_user.id
      |> ShoppingCart.get_cart_user()
    
    # Calcula o frete aleatoriamente (entre R$ 10,00 e R$ 50,00)
    shipping_cost = Decimal.new(:rand.uniform(40) + 10)
    
    socket = 
      socket
      |> assign(:current_user, current_user)
      |> assign(:cart_products, cart_products)
      |> assign(:shipping_cost, shipping_cost)
      |> assign(:page_title, "Meu Carrinho")

    {:ok, socket}
  end

  def handle_event("checkout", _params, socket) do
    {:noreply, 
     socket
     |> put_flash(:info, "Redirecionando para o checkout...")
     |> push_navigate(to: ~p"/checkout")}
  end

  def handle_event("remove_item", %{"cart_product_id" => cart_product_id}, socket) do
    cart_product_id = String.to_integer(cart_product_id)
    cart_product = ShoppingCart.get_cart_product(cart_product_id)
    
    case ShoppingCart.delete_cart_product(cart_product) do
      {:ok, _} ->
        updated_cart_products = Enum.reject(socket.assigns.cart_products, 
                                           &(&1.id == cart_product_id))
        
        {:noreply, 
         socket
         |> assign(:cart_products, updated_cart_products)
         |> put_flash(:info, "Item removido do carrinho")}
      
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erro ao remover item")}
    end
  end

  def handle_event("update_quantity", %{"cart_product_id" => cart_product_id, "quantity" => quantity}, socket) do
    cart_product_id = String.to_integer(cart_product_id)
    quantity_int = String.to_integer(quantity)
    
    if quantity_int > 0 do
      cart_product = ShoppingCart.get_cart_product(cart_product_id)
      
      case ShoppingCart.update_cart_product(cart_product, %{"quantity" => quantity}) do
        {:ok, updated_cart_product} ->
          updated_cart_products = Enum.map(socket.assigns.cart_products, fn cp ->
            if cp.id == cart_product_id do
              updated_cart_product
            else
              cp
            end
          end)
          
          {:noreply, 
           socket
           |> assign(:cart_products, updated_cart_products)
           |> put_flash(:info, "Quantidade atualizada")}
        
        {:error, _} ->
          {:noreply, put_flash(socket, :error, "Erro ao atualizar quantidade")}
      end
    else
      {:noreply, put_flash(socket, :error, "Quantidade deve ser maior que zero")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <.header class="mb-8">
        Meu Carrinho de Compras
        <:subtitle>Revise seus itens antes de finalizar a compra</:subtitle>
      </.header>

      <div class="grid grid-cols-1 gap-8 lg:grid-cols-3">
        <!-- Lista de itens do carrinho (2/3 da tela) -->
        <div class="lg:col-span-2">
          <%= if Enum.empty?(@cart_products) do %>
            <.empty_cart_state />
          <% else %>
            <div class="space-y-6">
              <%= for cart_product <- @cart_products do %>
                <.cart_item cart_product={cart_product} />
              <% end %>
            </div>
          <% end %>
        </div>

        <!-- Resumo do pedido (1/3 da tela) -->
        <%= if not Enum.empty?(@cart_products) do %>
          <div class="lg:col-span-1">
            <.order_summary 
              cart_products={@cart_products} 
              shipping_cost={@shipping_cost}
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Componente para estado vazio do carrinho
  defp empty_cart_state(assigns) do
    ~H"""
    <div class="text-center py-16">
      <.icon name="hero-shopping-cart" class="mx-auto h-16 w-16 text-gray-400" />
      <h3 class="mt-4 text-lg font-semibold text-gray-900">Seu carrinho está vazio</h3>
      <p class="mt-2 text-gray-600">Adicione produtos ao seu carrinho para continuar comprando</p>
      <div class="mt-6">
        <.link 
          navigate={~p"/products"} 
          class="inline-flex items-center rounded-md bg-indigo-600 px-6 py-3 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          <.icon name="hero-shopping-bag" class="-ml-0.5 mr-1.5 h-5 w-5" />
          Continuar Comprando
        </.link>
      </div>
    </div>
    """
  end

  # Componente para cada item do carrinho
  defp cart_item(assigns) do
    ~H"""
    <div class="rounded-lg border border-gray-200 bg-white p-6 shadow-sm">
      <div class="flex items-start gap-6">
        <!-- Imagem do produto -->
        <div class="h-24 w-24 flex-shrink-0 overflow-hidden rounded-lg border border-gray-200">
          <img 
            src={@cart_product.product.image_url} 
            alt={@cart_product.product.name}
            class="h-full w-full object-cover object-center"
          />
        </div>

        <!-- Informações do produto -->
        <div class="flex-1 space-y-4">
          <!-- Vendedor e nome do produto -->
          <div>
            <p class="text-sm text-gray-500">
              Vendido por: <span class="font-medium text-gray-700"><%= @cart_product.product.company.name %></span>
            </p>
            <h3 class="text-lg font-semibold text-gray-900 mt-1">
              <%= @cart_product.product.name %>
            </h3>
          </div>

          <!-- Controles de quantidade e preço -->
          <div class="flex items-center justify-between">
            <!-- Controle de quantidade -->
            <div class="flex items-center space-x-3">
              <.label>Quantidade:</.label>
              <div class="flex items-center rounded-md border border-gray-300">
                <.button 
                  phx-click="update_quantity" 
                  phx-value-cart_product_id={@cart_product.id}
                  phx-value-quantity={@cart_product.quantity - 1}
                  disabled={@cart_product.quantity <= 1}
                  class="!rounded-none !rounded-l-md px-3 py-1.5 text-sm"
                  size="sm"
                  variant="outline"
                >
                  <.icon name="hero-minus" class="h-4 w-4" />
                </.button>
                
                <span class="border-x border-gray-300 bg-gray-50 px-4 py-1.5 text-sm font-medium">
                  <%= @cart_product.quantity %>
                </span>
                
                <.button 
                  phx-click="update_quantity" 
                  phx-value-cart_product_id={@cart_product.id}
                  phx-value-quantity={@cart_product.quantity + 1}
                  class="!rounded-none !rounded-r-md px-3 py-1.5 text-sm"
                  size="sm"
                  variant="outline"
                >
                  <.icon name="hero-plus" class="h-4 w-4" />
                </.button>
              </div>
              <span class="text-sm text-gray-500">unidades</span>
            </div>

            <!-- Preço unitário -->
            <div class="text-right">
              <p class="text-lg font-bold text-gray-900">
                R$ <%= format_decimal(@cart_product.price_when_carted) %>
              </p>
              <p class="text-sm text-gray-500">preço total</p>
            </div>
          </div>

          <!-- Botão remover e subtotal -->
          <div class="flex items-center justify-between border-t border-gray-100 pt-4">
            <.button 
              phx-click="remove_item" 
              phx-value-cart_product_id={@cart_product.id}
              data-confirm="Tem certeza que deseja remover este item do carrinho?"
              variant="outline"
              size="sm"
              class="text-red-600 border-red-300 hover:bg-red-50"
            >
              <.icon name="hero-trash" class="mr-1.5 h-4 w-4" />
              Remover
            </.button>

            <p class="text-lg font-semibold text-gray-900">
              Subtotal: R$ <%= format_decimal(@cart_product.price_when_carted) %>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Componente para resumo do pedido
  defp order_summary(assigns) do
    ~H"""
    <div class="sticky top-4">
      <div class="rounded-lg bg-gray-50 p-6">
        <h2 class="text-lg font-semibold text-gray-900 mb-6">Resumo do Pedido</h2>
        
        <div class="space-y-4">
          <!-- Subtotal dos produtos -->
          <div class="flex justify-between text-gray-600">
            <span>Subtotal dos produtos:</span>
            <span>R$ <%= format_decimal(BatchEcommerce.ShoppingCart.total_price_cart_product(@cart_products)) %></span>
          </div>
          
          <!-- Frete -->
          <div class="flex justify-between text-gray-600">
            <div class="flex items-center space-x-1">
              <span>Frete:</span>
              <.icon name="hero-truck" class="h-4 w-4" />
            </div>
            <span>R$ <%= format_decimal(@shipping_cost) %></span>
          </div>
          
          <hr class="border-gray-300">
          
          <!-- Total -->
          <div class="flex justify-between text-lg font-bold text-gray-900">
            <span>Total:</span>
            <span>R$ <%= format_decimal(total_with_shipping(@cart_products, @shipping_cost)) %></span>
          </div>
        </div>
        
        <!-- Botões de ação -->
        <div class="mt-6 space-y-3">
          <.button 
            phx-click="checkout"
            class="w-full bg-green-600 hover:bg-green-700 focus:ring-green-500"
          >
            <.icon name="hero-credit-card" class="mr-2 h-5 w-5" />
            Concluir Compra
          </.button>
          
          <.link 
            navigate={~p"/products"} 
            class="block w-full text-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
          >
            <.icon name="hero-arrow-left" class="mr-1.5 h-4 w-4 inline" />
            Continuar Comprando
          </.link>
        </div>
      </div>
    </div>
    """
  end

  # Funções auxiliares
  defp total_with_shipping(cart_products, shipping_cost) do
    cart_total = BatchEcommerce.ShoppingCart.total_price_cart_product(cart_products)
    Decimal.add(cart_total, shipping_cost)
  end

  defp format_decimal(decimal) do
    decimal
    |> Decimal.to_string(:normal)
    |> String.replace(".", ",")
  end
end