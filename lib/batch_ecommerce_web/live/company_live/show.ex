defmodule BatchEcommerceWeb.Live.CompanyLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Catalog

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")
    user = Accounts.get_user(user_id)

    case Accounts.get_company_by_user_id(user_id) do
      nil ->
        {:ok, assign(socket,
          has_company: false,
          user: user
        )}

      company ->
        top_products = Catalog.get_top_selling_products(company.id)
        {:ok,
         socket
         |> assign(:has_company, true)
         |> assign(:company, company)
         |> assign(:user, user)
         |> assign(:top_products, top_products)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  defp get_product_rating(product_id) do
    Catalog.get_product_rating(product_id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} company={@company} id="HeaderDefault"/>

    <%= if @has_company do %>
      <div class="mx-20 mt-[70px] grid grid-cols-[3fr_1fr] pl-[250px] py-8">
        <div>
          <!-- Nome da empresa em destaque -->
          <div class="bg-white p-5 rounded-lg">
            <h1 class="text-3xl font-bold text-gray-800">
              <%= @company.name %>
            </h1>
            <p class="text-lg text-gray-600 mt-2">
              Painel Administrativo
            </p>
          </div>

          <!-- Tabela de produtos -->
          <div class="px-[15px] py-[7px] mt-[10px] bg-white rounded-lg">
            <.table id="top-products" rows={@top_products}>
              <:col :let={product} label="Nome do Produto">
                <%= product.name %>
              </:col>
              <:col :let={product} label="Quantidade Vendida">
                <%= product.sales_quantity %>
              </:col>
              <:col :let={product} label="Quantidade em Carrinhos">
                <%= BatchEcommerce.ShoppingCart.total_cart_products_quantity(product.id) %>
              </:col>
              <:col :let={product} label="Classificação">
                <%= get_product_rating(product.id) %>/5
              </:col>
            </.table>
          </div>
        </div>

        <!-- Botões de ação com verificação -->
        <div class="flex flex-col items-center space-y-4 mt-[125px]">
          <div>
            <.link patch={~p"/companies/#{@company.id}/products"}>
              <.button class="flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-800 transition duration-200 text-white font-semibold py-2 px-6 rounded-lg shadow mb-3 min-w-[200px]">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 6.75V5.25A3.75 3.75 0 0012.75 1.5h-1.5A3.75 3.75 0 007.5 5.25v1.5M3 6.75h18l-.75 12.75a2.25 2.25 0 01-2.25 2.25H6a2.25 2.25 0 01-2.25-2.25L3 6.75z"></path>
                </svg>
                Produtos
              </.button>
            </.link>
          </div>
          <div>
            <.link patch={~p"/companies/#{@company.id}/orders"}>
              <.button class="flex items-center justify-center gap-2 bg-indigo-600 hover:bg-indigo-800 transition duration-200 text-white font-semibold py-2 px-6 rounded-lg shadow mb-3 min-w-[200px]">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 3.75h6a1.5 1.5 0 011.5 1.5v.75H18a1.5 1.5 0 011.5 1.5v12A1.5 1.5 0 0118 21H6a1.5 1.5 0 01-1.5-1.5v-12A1.5 1.5 0 016 6h1.5v-.75a1.5 1.5 0 011.5-1.5z"></path>
                </svg>
                Pedidos
              </.button>
            </.link>
          </div>
          <div>
            <.link patch={~p"/companies/#{@company.id}/edit"}>
              <.button class="flex items-center justify-center gap-2 bg-indigo-400 hover:bg-indigo-600 transition duration-200 text-white font-semibold py-2 px-6 rounded-lg shadow mb-3 min-w-[200px]">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M11.25 1.5v1.86m0 17.28v1.86m8.3-11.01h1.86M2.55 12h1.86m14.36-7.78l-1.32 1.32M4.65 19.35l1.32-1.32m0-12.66L4.65 4.65m14.7 14.7l-1.32-1.32M12 8.25a3.75 3.75 0 100 7.5 3.75 3.75 0 000-7.5z"></path>
                </svg>
                Alterar Dados
              </.button>
            </.link>
          </div>
        </div>
      </div>
    <% else %>
      <!-- Mensagem e botão para cadastrar empresa -->
      <div class="max-w-md mx-auto px-4 py-20 text-center">
        <p class="text-xl text-gray-600 mb-6">
          Você não possui uma empresa cadastrada ainda, o que está esperando?
        </p>
        <p class="text-lg text-gray-500 mb-8">
          Cadastre agora!
        </p>

        <.link navigate={~p"/companies/new"} class="inline-block">
          <.button class="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-3 rounded-lg text-lg">
            Cadastrar Empresa
          </.button>
        </.link>
      </div>
    <% end %>
    """
  end
end
