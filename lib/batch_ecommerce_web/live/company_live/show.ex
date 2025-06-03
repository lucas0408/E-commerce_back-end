# lib/batch_ecommerce_web/live/company_live/show.ex
defmodule BatchEcommerceWeb.Live.CompanyLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Catalog

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    company = Accounts.get_company!(id)
    IO.inspect(company)
    top_products = get_top_5_selling_products_by_sales(company.products)

    {:ok,
     socket
     |> assign(:company, company)
     |> assign(:user, %{name: "ricardo", id: 1})
     |> assign(:top_products, top_products)}
  end

  def get_top_5_selling_products_by_sales(products) do
    products
    |> Enum.sort_by(& &1.sales_quantity, :desc)
    |> Enum.take(5)
  end




  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
      <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} id="HeaderDefault"/>
    <div class="max-w-6xl mx-auto px-4 py-20">
      <!-- Tabela de produtos -->
      <div class="px-[15px] py-[7px] mt-[20px] bg-white rounded-lg">
        <.table id="top-products" rows={@top_products}>
          <:col :let={product} label="Nome do Produto">
            <%= product.name %>
          </:col>
          <:col :let={product} label="Quantidade Vendida">
            <%= product.sales_quantity %>
          </:col>
          <:col :let={product} label="Quantidade em Carrinhos">
            <%= product.stock_quantity %>
          </:col>
          <:col :let={product} label="Classificação">
            <%= product.rating %>
          </:col>
        </.table>
      </div>

      <!-- Botões de ação com verificação -->
      <div class="flex justify-center space-x-10 mt-[50px]">

      <.link patch={~p"/companies/#{@company.id}/products"}>
        <.button
        >
          Produtos
        </.button>
      </.link>

      <.link patch={~p"/companies/#{@company.id}/orders"}>
        <.button
        >
          Pedidos
        </.button>
      </.link>

      <.link patch={~p"/companies/#{@company.id}/edit"}>
        <.button
        >
          Alterar Dados
        </.button>
      </.link>

      </div>
    </div>
    """
  end
end
