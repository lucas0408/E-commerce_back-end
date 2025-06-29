defmodule BatchEcommerceWeb.Live.ShoppingCart.Index do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.ShoppingCart
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts

  def mount(_params, session, socket) do
    current_user = session["user_id"]

    current_user = Accounts.get_user(current_user)

    cart_products =
      session["user_id"]
      |> ShoppingCart.get_cart_user()

    socket =
      socket
      |> assign(:show_payment_modal, false)
      |> assign(:selected_payment_method, nil)
      |> assign(:show_address_modal, false)
      |> assign(:selected_address_id, nil)
      |> assign(:current_user, current_user)
      |> assign(:cart_products, cart_products)
      |> assign(:shipping_cost, Decimal.new("0"))
      |> assign(:page_title, "Meu Carrinho")

    {:ok, socket}
  end

  def handle_event("proceed_to_checkout", _params, socket) do
    if Enum.empty?(socket.assigns.cart_products) do
      {:noreply, put_flash(socket, :error, "Seu carrinho está vazio")}
    else
      # Usamos os valores já disponíveis no socket.assigns
      case Orders.complete_order(socket.assigns.current_user.id, socket.assigns.shipping_cost) do
        {:ok, _order} ->
          {:noreply,
          socket
          |> put_flash(:info, "Compra realizada com sucesso")
          |> push_redirect(to: ~p"/orders")}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, "Erro ao processar pedido")}
      end
    end
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

  def handle_event("update_quantity", %{"cart_product_id" => id, "quantity" => qty}, socket) do
    cart_product = ShoppingCart.get_cart_product(String.to_integer(id))

    case ShoppingCart.update_cart_product(cart_product, %{"quantity" => qty}) do
      {:ok, updated} ->
        cart_products = Enum.map(socket.assigns.cart_products, &(&1.id == updated.id && updated || &1))
        {:noreply, assign(socket, :cart_products, cart_products)}

      _ ->
        {:noreply, put_flash(socket, :error, "Erro na atualização")}
    end
  end

  def handle_event("select_address", %{"address_id" => address_id}, socket) do
    {:noreply, assign(socket, :selected_address_id, String.to_integer(address_id))}
  end

  def handle_event("toggle_address_modal", _, socket) do
    {:noreply, assign(socket, :show_address_modal, !socket.assigns.show_address_modal)}
  end

  def handle_event("delete_address", %{"address_id" => address_id}, socket) do
    address_id = String.to_integer(address_id)
    # Implemente a função de deletar endereço no seu contexto
    address = Accounts.get_address(address_id)
    case Accounts.delete_address(address) do
      {:ok, _} ->
        updated_user = Accounts.get_user(socket.assigns.current_user.id)
        {:noreply,
        socket
        |> assign(:current_user, updated_user)
        |> put_flash(:info, "Endereço removido com sucesso")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Erro ao remover endereço")}
    end
  end

  def handle_event("confirm_address", _, socket) do
    if socket.assigns.selected_address_id do
      shipping_cost = Decimal.new(:rand.uniform(40) + 10)
      {:noreply,
      socket
      |> assign(:show_address_modal, false)
      |> assign(:shipping_cost, shipping_cost)
      |> put_flash(:info, "Endereço selecionado com sucesso")}
    else
      {:noreply, put_flash(socket, :error, "Selecione um endereço")}
    end
  end

  def handle_event("toggle_payment_modal", _, socket) do
    {:noreply, assign(socket, :show_payment_modal, !socket.assigns.show_payment_modal)}
  end

  def handle_event("select_payment_method", %{"method" => method}, socket) do
    {:noreply, assign(socket, :selected_payment_method, method)}
  end

  def handle_event("confirm_payment", _, socket) do
    if socket.assigns.selected_payment_method do
      {:noreply,
      socket
      |> assign(:show_payment_modal, false)
      |> put_flash(:info, "Método de pagamento selecionado: #{socket.assigns.selected_payment_method}")}
    else
      {:noreply, put_flash(socket, :error, "Selecione um método de pagamento")}
    end
  end

  defp payment_modal(assigns) do
  ~H"""
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 z-50 overflow-y-auto">
    <div class="flex min-h-full items-center justify-center p-4">
      <div class="w-full max-w-md transform rounded-lg bg-white p-6 shadow-xl">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-medium text-gray-900">Selecione a forma de pagamento</h3>
          <button
            phx-click="toggle_payment_modal"
            class="text-gray-400 hover:text-gray-500"
          >
            <.icon name="hero-x-mark" class="h-6 w-6" />
          </button>
        </div>

        <div class="space-y-4">
          <!-- Opção PIX -->
          <div class="flex items-start">
            <input
              type="radio"
              id="payment-pix"
              name="payment_method"
              value="PIX"
              checked={@selected_payment_method == "PIX"}
              class="mt-1 h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
              phx-click="select_payment_method"
              phx-value-method="PIX"
            />
            <label for="payment-pix" class="ml-3 block flex-1">
              <div class="border rounded-lg p-4 hover:border-indigo-500">
                <div class="flex items-center">
                  <.icon name="hero-currency-dollar" class="h-6 w-6 text-green-500 mr-2" />
                  <span class="font-medium">PIX</span>
                </div>
                <p class="text-sm text-gray-500 mt-1">Pagamento instantâneo com 5% de desconto</p>
              </div>
            </label>
          </div>

          <!-- Opção Cartão de Crédito -->
          <div class="flex items-start">
            <input
              type="radio"
              id="payment-credit"
              name="payment_method"
              value="Cartão de Crédito"
              checked={@selected_payment_method == "Cartão de Crédito"}
              class="mt-1 h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
              phx-click="select_payment_method"
              phx-value-method="Cartão de Crédito"
            />
            <label for="payment-credit" class="ml-3 block flex-1">
              <div class="border rounded-lg p-4 hover:border-indigo-500">
                <div class="flex items-center">
                  <.icon name="hero-credit-card" class="h-6 w-6 text-blue-500 mr-2" />
                  <span class="font-medium">Cartão de Crédito</span>
                </div>
                <p class="text-sm text-gray-500 mt-1">Parcelamento em até 12x</p>
              </div>
            </label>
          </div>

          <!-- Opção Cartão de Débito -->
          <div class="flex items-start">
            <input
              type="radio"
              id="payment-debit"
              name="payment_method"
              value="Cartão de Débito"
              checked={@selected_payment_method == "Cartão de Débito"}
              class="mt-1 h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
              phx-click="select_payment_method"
              phx-value-method="Cartão de Débito"
            />
            <label for="payment-debit" class="ml-3 block flex-1">
              <div class="border rounded-lg p-4 hover:border-indigo-500">
                <div class="flex items-center">
                  <.icon name="hero-banknotes" class="h-6 w-6 text-purple-500 mr-2" />
                  <span class="font-medium">Cartão de Débito</span>
                </div>
                <p class="text-sm text-gray-500 mt-1">Pagamento à vista</p>
              </div>
            </label>
          </div>
        </div>

        <div class="mt-6">
          <.button
            phx-click="proceed_to_checkout"
            disabled={is_nil(@selected_payment_method)}
            class="w-full justify-center rounded-md bg-green-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-green-500 disabled:bg-gray-400"
          >
            Confirmar Pagamento
          </.button>
        </div>
      </div>
    </div>
  </div>
  """
  end

  def render(assigns) do
    ~H"""
      <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderWithCart} user={@current_user} id="HeaderWithCart"/>
    <div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">

      <!-- Modal de endereços -->
      <%= if @show_address_modal do %>
        <.address_modal
          current_user={@current_user}
          selected_address_id={@selected_address_id}
        />
      <% end %>

      <!-- Modal de pagamento -->
      <%= if @show_payment_modal do %>
        <.payment_modal selected_payment_method={@selected_payment_method} />
      <% end %>

      <div class="grid grid-cols-1 gap-8">
        <!-- Lista de itens do carrinho (2/3 da tela) -->
        <div class="lg:col-span-2">
          <%= if Enum.empty?(@cart_products) do %>
            <.empty_cart_state />
          <% else %>
            <div class="space-y-6 lg:grid-cols-3">
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
          class="inline-flex items-center rounded-md bg-indigo-600 px-6 py-3 text-sm font-semibold text-white shadow-sm hover:bg-indigo-800 hover:scale-105 transition duration-200 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
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
                  disabled={@cart_product.quantity >= (@cart_product.product.stock_quantity || 0)}
                >
                  <.icon name="hero-plus" class="h-4 w-4" />
                </.button>
              </div>
              <span class="text-sm text-gray-500">unidades</span>
            </div>

            <!-- Preço unitário -->
            <div class="text-right">
              <%
                price = @cart_product.price_when_carted
                discount = @cart_product.product.discount || 0
                discounted_price = calculate_discounted_price(price, discount)
              %>

              <%= if Decimal.cmp(discounted_price, price) == :lt do %>
                <p class="text-sm text-gray-500 line-through">
                  R$ <%= format_decimal(price) %>
                </p>
                <p class="text-lg font-bold text-green-600">
                  R$ <%= format_decimal(discounted_price) %>
                </p>
              <% else %>
                <p class="text-lg font-bold text-gray-900">
                  R$ <%= format_decimal(price) %>
                </p>
              <% end %>
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
          <div
            class="flex justify-between text-gray-600 cursor-pointer hover:bg-gray-100 p-2 rounded"
            phx-click="toggle_address_modal"
          >
            <div class="flex items-center space-x-1">
              <span>Frete:</span>
              <.icon name="hero-truck" class="h-4 w-4" />
            </div>
            <span>R$ <%= format_decimal(@shipping_cost) %></span>
          </div>

          <hr class="border-gray-300">

          <!-- Total com frete (novo campo destacado) -->
          <div class="bg-white p-3 rounded-lg border border-gray-200 shadow-sm">
            <div class="flex justify-between items-center">
              <span class="font-bold text-lg">Total a pagar:</span>
              <span class="text-2xl font-bold text-green-600">
                R$ <%= format_decimal(total_with_shipping(@cart_products, @shipping_cost)) %>
              </span>
            </div>
          </div>
        </div>

    <!-- Botões de ação -->
        <div class="mt-6 space-y-3">
          <%= if @shipping_cost == Decimal.new("0") do %>
            <.button
              phx-click="toggle_address_modal"
              class="w-full bg-yellow-500 hover:bg-yellow-600"
            >
              <.icon name="hero-truck" class="mr-2 h-5 w-5" />
              Calcular Frete Primeiro
            </.button>
          <% else %>
            <.button
              phx-click="toggle_payment_modal"
              class="w-full bg-green-600 hover:bg-green-700"
            >
              <.icon name="hero-credit-card" class="mr-2 h-5 w-5" />
              Concluir Compra
            </.button>
          <% end %>
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

  defp address_modal(assigns) do
  ~H"""
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 z-50 overflow-y-auto">
    <div class="flex min-h-full items-center justify-center p-4">
      <div class="w-full max-w-2xl transform rounded-lg bg-white p-6 shadow-xl">
        <div class="flex justify-between items-center mb-6">
          <h3 class="text-lg font-medium text-gray-900">Selecione um endereço</h3>
          <button
            phx-click="toggle_address_modal"
            class="text-gray-400 hover:text-gray-500"
          >
            <.icon name="hero-x-mark" class="h-6 w-6" />
          </button>
        </div>

        <div class="space-y-4 max-h-96 overflow-y-auto">
          <%= for address <- @current_user.addresses do %>
            <div class="flex items-start">
              <input
                type="radio"
                id={"address-#{address.id}"}
                name="selected_address"
                value={address.id}
                checked={@selected_address_id == address.id}
                class="mt-1 h-4 w-4 text-indigo-600 border-gray-300 focus:ring-indigo-500"
                phx-click="select_address"
                phx-value-address_id={address.id}
              />

              <label
                for={"address-#{address.id}"}
                class="ml-3 block flex-1"
              >
                <div class="border rounded-lg p-4 hover:border-indigo-500">
                  <div class="flex justify-between">
                    <span class="font-medium">
                      <%= address.district %>, <%= address.city %> - <%= address.uf %>
                    </span>
                    <button
                      phx-click="delete_address"
                      phx-value-address_id={address.id}
                      class="text-gray-400 hover:text-red-500"
                    >
                      <.icon name="hero-trash" class="h-5 w-5" />
                    </button>
                  </div>
                  <p class="text-sm text-gray-500 mt-1">
                    <%= address.address %>, <%= address.home_number %>
                    <%= if address.complement != "", do: " - #{address.complement}" %>
                  </p>
                  <p class="text-sm text-gray-500 mt-1">
                    CEP: <%= address.cep %>
                  </p>
                </div>
              </label>
            </div>
          <% end %>
        </div>

        <div class="mt-6 flex justify-between">
          <.link
            navigate={~p"/address/new"}
            class="inline-flex items-center rounded-md bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-500"
          >
            <.icon name="hero-plus" class="-ml-1 mr-2 h-5 w-5" />
            Adicionar novo endereço
          </.link>

          <.button
            phx-click="confirm_address"
            disabled={is_nil(@selected_address_id)}
            class="inline-flex items-center rounded-md bg-green-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-green-500 disabled:bg-gray-400"
          >
            Confirmar Endereço
          </.button>
        </div>
      </div>
    </div>
  </div>
  """
  end

  defp total_with_shipping(cart_products, shipping_cost) do
    Decimal.add(BatchEcommerce.ShoppingCart.total_price_cart_product(cart_products), shipping_cost)
  end


  defp calculate_discounted_price(price, discount) when is_nil(discount) or discount == 0 do
    price
  end

  defp calculate_discounted_price(price, discount) do
    discount_decimal = Decimal.new(discount)
    hundred = Decimal.new(100)
    discount_factor = Decimal.sub(hundred, discount_decimal) |> Decimal.div(hundred)
    Decimal.mult(price, discount_factor)
    |> Decimal.round(2)
  end


  defp format_decimal(decimal) do
    decimal
    |> Decimal.to_string(:normal)
    |> String.replace(".", ",")
  end
end
