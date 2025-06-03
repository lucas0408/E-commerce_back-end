defmodule BatchEcommerceWeb.Live.ProductLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog
  import BatchEcommerceWeb.CoreComponents
  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.Accounts

  @impl true
  def mount(%{"product_id" => id}, session, socket) do
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)
    product = Catalog.get_product(id)
    {:ok,
     socket
     |> assign(:product, product)
     |> assign(:current_user, current_user)
     |> assign(:quantity, 1)
     |> assign(:loading, false)}
  end

  @impl true
  def handle_event("update_quantity", %{"quantity" => quantity}, socket) do
    quantity = String.to_integer(quantity)
    max_quantity = socket.assigns.product.stock_quantity || 0
    
    # Limita a quantidade ao estoque disponível
    quantity = if quantity > max_quantity, do: max_quantity, else: quantity
    quantity = if quantity < 1, do: 1, else: quantity
    
    {:noreply, assign(socket, :quantity, quantity)}
  end

  @impl true
  def handle_event("add_to_cart", _params, socket) do
    %{product: product, quantity: quantity, current_user: current_user} = socket.assigns

    ShoppingCart.create_cart_prodcut(current_user.id, %{
      "product_id" => product.id,
      "quantity" => quantity
    })

    {:noreply,
    socket
    |> put_flash(:info, "Produto adicionado ao carrinho com sucesso!")
    |> push_redirect(to: "/cart_products")}
  end


  # Função auxiliar para calcular o preço com desconto
  defp calculate_discounted_price(price, discount) when is_nil(discount) or discount == 0 do
    price
  end
  
  defp calculate_discounted_price(price, discount) do
    discount_decimal = Decimal.new(discount)
    hundred = Decimal.new(100)
    discount_factor = Decimal.sub(hundred, discount_decimal) |> Decimal.div(hundred)
    Decimal.mult(price, discount_factor)
  end

  # Função auxiliar para formatar preço
  defp format_price(price) when is_nil(price), do: "0,00"
  
  defp format_price(%Decimal{} = price) do
    price
    |> Decimal.to_string()
    |> String.replace(".", ",")
  end
  
  defp format_price(price) when is_number(price) do
    price
    |> :erlang.float_to_binary(decimals: 2)
    |> String.replace(".", ",")
  end

  # Função auxiliar para renderizar estrelas de rating
  defp render_stars(rating) when is_nil(rating), do: {0, false, 5}
  
  defp render_stars(rating) do
    # Limita o rating entre 0 e 5
    rating = max(0, min(rating, 5))
    
    full_stars = trunc(rating)
    has_half_star = rating - full_stars >= 0.5
    empty_stars = 5 - full_stars - (if has_half_star, do: 1, else: 0)
    
    # Garante que nunca ultrapasse 5 estrelas no total
    full_stars = min(full_stars, 5)
    empty_stars = max(empty_stars, 0)
    
    {full_stars, has_half_star, empty_stars}
  end

  # Função auxiliar para obter desconto ou 0 se nil
  defp get_discount(nil), do: 0
  defp get_discount(discount), do: discount

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white">
      <div class="mx-auto max-w-2xl px-4 py-16 sm:px-6 sm:py-24 lg:max-w-7xl lg:px-8">
        <div class="lg:grid lg:grid-cols-2 lg:items-start lg:gap-x-8">
          <!-- Coluna da esquerda - Imagem e informações básicas -->
          <div class="flex flex-col">
            <!-- Nome do produto -->
            <.header class="mb-6">
              <%= @product.name %>
            </.header>

            <!-- Imagem do produto -->
            <div class="aspect-h-1 aspect-w-1 w-full">
              <img 
                src={@product.image_url} 
                alt={@product.name}
                class="h-full w-full object-cover object-center sm:rounded-lg"
              />
            </div>

            <!-- Rating -->
            <div class="mt-6 flex items-center">
              <div class="flex items-center">
                <% {full_stars, has_half_star, _empty_stars} = render_stars(@product.rating) %>
                
                <!-- Estrelas cheias -->
                <%= for _i <- 1..full_stars do %>
                  <svg class="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                <% end %>
                
                <!-- Meia estrela -->
                <%= if has_half_star do %>
                  <svg class="h-5 w-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                    <defs>
                      <linearGradient id="half-star">
                        <stop offset="50%" stop-color="currentColor"/>
                        <stop offset="50%" stop-color="transparent"/>
                      </linearGradient>
                    </defs>
                    <path fill="url(#half-star)" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                <% end %>
              </div>
              <span class="ml-2 text-sm text-gray-600">(<%= @product.rating || 0 %>/5)</span>
            </div>

            <!-- Descrição -->
            <div class="mt-6">
              <h3 class="text-sm font-medium text-gray-900">Descrição</h3>
              <div class="mt-4 space-y-6">
                <p class="text-sm text-gray-600"><%= @product.description %></p>
              </div>
            </div>
          </div>

          <!-- Coluna da direita - Preços e ações -->
          <div class="mt-10 px-4 sm:mt-16 sm:px-0 lg:mt-0">
            <div class="space-y-6">
              <!-- Preços -->
              <div class="space-y-2">
                <%= if get_discount(@product.discount) > 0 do %>
                  <!-- Preço original riscado -->
                  <div class="flex items-center space-x-2">
                    <span class="text-sm text-gray-500">De:</span>
                    <span class="text-lg text-gray-500 line-through">
                      R$ <%= format_price(@product.price) %>
                    </span>
                  </div>
                  
                  <!-- Preço com desconto -->
                  <div class="flex items-center space-x-3">
                    <span class="text-3xl font-bold text-gray-900">
                      R$ <%= format_price(calculate_discounted_price(@product.price, @product.discount)) %>
                    </span>
                    <span class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800">
                      <%= get_discount(@product.discount) %>% OFF
                    </span>
                  </div>
                <% else %>
                  <!-- Preço sem desconto -->
                  <div class="text-3xl font-bold text-gray-900">
                    R$ <%= format_price(@product.price) %>
                  </div>
                <% end %>
              </div>

              <!-- Quantidade em estoque -->
              <div class="flex items-center space-x-2">
                <span class="text-sm font-medium text-gray-900">Estoque:</span>
                <span class={[
                  "text-sm font-medium",
                  if((@product.stock_quantity || 0) > 10, do: "text-green-600", else: ""),
                  if((@product.stock_quantity || 0) <= 10 and (@product.stock_quantity || 0) > 0, do: "text-yellow-600", else: ""),
                  if((@product.stock_quantity || 0) == 0, do: "text-red-600", else: "")
                ]}>
                  <%= if (@product.stock_quantity || 0) > 0 do %>
                    <%= @product.stock_quantity %> unidades disponíveis
                  <% else %>
                    Produto indisponível
                  <% end %>
                </span>
              </div>

              <%= if (@product.stock_quantity || 0) > 0 do %>
                <!-- Seletor de quantidade -->
                <div class="space-y-2">
                  <label class="text-sm font-medium text-gray-900">Quantidade:</label>
                  <div class="flex items-center space-x-3">
                    <.button 
                      type="button" 
                      variant="outline" 
                      size="sm"
                      phx-click="update_quantity" 
                      phx-value-quantity={@quantity - 1}
                      disabled={@quantity <= 1}
                    >
                      -
                    </.button>
                    
                    <.input 
                      type="number" 
                      value={@quantity}
                      min="1"
                      max={@product.stock_quantity || 0}
                      phx-change="update_quantity"
                      name="quantity"
                      class="w-20 text-center"
                    />
                    
                    <.button 
                      type="button" 
                      variant="outline" 
                      size="sm"
                      phx-click="update_quantity" 
                      phx-value-quantity={@quantity + 1}
                      disabled={@quantity >= (@product.stock_quantity || 0)}
                    >
                      +
                    </.button>
                  </div>
                </div>

                <!-- Botão adicionar ao carrinho -->
                <div class="mt-8">
                  <.button 
                    type="button"
                    class="w-full"
                    phx-click="add_to_cart"
                    disabled={@loading}
                  >
                    <%= if @loading do %>
                      Adicionando...
                    <% else %>
                      Adicionar ao Carrinho
                    <% end %>
                  </.button>
                </div>
              <% else %>
                <!-- Produto indisponível -->
                <div class="mt-8">
                  <.button type="button" class="w-full" disabled>
                    Produto Indisponível
                  </.button>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end