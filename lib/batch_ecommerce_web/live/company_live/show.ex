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

  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} id="HeaderDefault"/>

    <%= if @has_company do %>
      <div class="max-w-6xl mx-auto mt-[20px] px-4 py-8"> <!-- Reduzi o padding-top para 8 -->
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

        <!-- Botões de ação com verificação -->
        <div class="flex justify-center space-x-10 mt-[50px]">
          <.link patch={~p"/companies/#{@company.id}/products"}>
            <.button>Produtos</.button>
          </.link>

          <.link patch={~p"/companies/#{@company.id}/orders"}>
            <.button>Pedidos</.button>
          </.link>

          <.link patch={~p"/companies/#{@company.id}/edit"}>
            <.button>Alterar Dados</.button>
          </.link>
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
