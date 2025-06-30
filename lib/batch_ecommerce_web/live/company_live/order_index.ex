defmodule BatchEcommerceWeb.Live.CompanyLive.OrderIndex do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Accounts

  @per_page 4

  @impl true
  def mount(%{"company_id" => company_id}, session, socket) do
    user_id = Map.get(session, "user_id")
    current_user = Accounts.get_user(user_id)
    {:ok,
    socket
    |> assign(:company_id, company_id)
    |> assign(:orders, [])
    |> assign(:page, 1)
    |> assign(:per_page, @per_page)
    |> assign(:total_pages, 1)
    |> assign(:user, current_user)
    |> assign(:filters, %{status: "", customer: ""})
    |> load_orders()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = params |> Map.get("page", "1") |> String.to_integer()
    {:noreply, socket |> assign(:page, page) |> load_orders()}
  end

  defp load_orders(socket) do
    %{company_id: company_id, page: page, per_page: per_page, filters: filters} = socket.assigns

    %{entries: orders, total_pages: total_pages} =

    %{entries: orders, total_pages: total_pages} =
      Orders.list_company_orders_paginated(
        company_id,
        page,
        per_page,
        status: filters.status,
        customer: filters.customer
      )


    socket
    |> assign(:orders, orders)
    |> assign(:total_pages, total_pages)
  end

  @impl true
  def handle_event("nav", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply,
     socket
     |> assign(:page, page)
     |> load_orders()}
  end

  @impl true
  def handle_event("filter_by_customer", %{"customer_name" => customer_name}, socket) do
    new_filters = %{
      status: socket.assigns.filters.status, # Mantém o filtro de status atual
      customer: customer_name
    }

    {:noreply,
    socket
    |> assign(:filters, new_filters)
    |> assign(:page, 1)
    |> load_orders()}
  end

  @impl true
  def handle_event("filter", params, socket) do


    current_filters = socket.assigns.filters


    new_filters = %{
      status: Map.get(params, "status", current_filters.status),
      customer: String.trim(Map.get(params, "customer", current_filters.customer || ""))
    }

    {:noreply,
    socket
    |> assign(:filters, new_filters)
    |> assign(:page, 1)
    |> load_orders()}
  end

  @impl true
  def handle_event("clear_filters", _, socket) do
    # Remove todos os filtros
    {:noreply,
    socket
    |> assign(:filters, %{status: "", customer: ""})
    |> assign(:page, 1)
    |> load_orders()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} company={@current_company} id="HeaderDefault"/>

    <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Botão Voltar -->
      <div class="mb-4">
        <.link navigate={~p"/companies"} class="inline-flex items-center text-gray-400 hover:text-gray-700">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clip-rule="evenodd" />
          </svg>
          Voltar
        </.link>
      </div>

    <!-- Filtros com form -->
    <div class="mb-6 bg-white p-4 rounded-lg shadow">
      <%= if @filters.customer != "" do %>
        <div class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-md">
          <div class="flex items-center justify-between">
            <span class="text-sm text-blue-800">
              <strong>Filtrando por cliente:</strong> <%= @filters.customer %>
            </span>
            <button
            <button
              type="button"
              phx-click="clear_customer_filter"
              phx-click="clear_customer_filter"
              class="text-blue-600 hover:text-blue-800 text-sm underline"
            >
              Remover filtro
            </button>
          </div>
        </div>
      <% end %>


      <.form for={%{}} phx-change="filter" class="grid grid-cols-1 md:grid-cols-2 gap-4 items-end">
        <!-- Filtro por Status -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
          <select
            name="status"
          <select
            name="status"
            class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
          >
            <option value="" selected={@filters.status == ""}>Todos</option>
            <option value="Preparando Pedido" selected={@filters.status == "Preparando Pedido"}>Preparando Pedido</option>
            <option value="Enviado" selected={@filters.status == "Enviado"}>Enviado</option>
            <option value="A Caminho" selected={@filters.status == "A Caminho"}>A Caminho</option>
            <option value="Entregue" selected={@filters.status == "Entregue"}>Entregue</option>
            <option value="Cancelado" selected={@filters.status == "Cancelado"}>Cancelado</option>
          </select>
        </div>

        <!-- Botão Limpar Filtros -->
        <div class="flex items-end">
          <button
          <button
            type="button"
            phx-click="clear_filters"
            phx-click="clear_filters"
            class="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
          >
            Limpar Todos os Filtros
          </button>
        </div>
      </.form>
    </div>



    <!-- Tabela de pedidos -->
    <div class="mt-8 flow-root bg-white px-[10px] py-[1px] rounded-lg">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <table class="min-w-full divide-y divide-gray-300">
            <thead class="text-zinc-500">
              <tr>
                <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold sm:pl-0">Produto</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Cliente</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Quantidade</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Status</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Total</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Ação</th>
                <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-0">
                  <span class="sr-only">Ações</span>
                </th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200 bg-white">
              <%= for order_product <- @orders do %>
                <tr>
                  <td class="whitespace-nowrap py-5 pl-4 pr-3 text-sm sm:pl-0">
                    <div class="flex items-center">
                      <div class="h-11 w-11 flex-shrink-0">
                        <img class="h-11 w-11 rounded-full" src={order_product.product.filename} alt={order_product.product.name}>
                      </div>
                      <div class="ml-4">
                        <div class="font-medium text-gray-900"><%= order_product.product.name %></div>
                      </div>
                    </div>
                  </td>
                  <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                    <div
                    <div
                      class="text-gray-900 cursor-pointer hover:text-indigo-600 hover:underline transition-colors duration-200"
                      phx-click="filter_by_customer"
                      phx-click="filter_by_customer"
                      phx-value-customer_name={order_product.order.user.name}
                      title="Clique para filtrar por este cliente"
                    >
                      <%= order_product.order.user.name %>
                    </div>
                    <div class="mt-1 text-gray-500"><%= order_product.order.user.email %></div>
                  </td>
                  <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                    <%= order_product.quantity %>
                  </td>
                  <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                    <span class="inline-flex items-center rounded-md bg-green-50 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/20">
                      <%= order_product.status %>
                    </span>
                  </td>
                  <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                    R$ <%= order_product.price |> Decimal.round(2) |> Decimal.to_string(:normal) %>
                  </td>
                  <td class="relative whitespace-nowrap py-5 pl-3 pr-4 text-right text-sm font-medium sm:pr-0">
                    <.link
                      patch={~p"/companies/#{@company_id}/orders/#{order_product.id}"}
                      class="text-indigo-600 hover:text-indigo-900"
                    >
                      Ver mais
                    </.link>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>

      <!-- Paginação -->
      <nav class="flex items-center justify-between border-t border-gray-200 px-4 py-3 sm:px-0 mt-4">
        <div class="flex flex-1 justify-between sm:hidden">
          <%= if @page > 1 do %>
            <a
              href="#"
            <a
              href="#"
              class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
              phx-click="nav"
              phx-click="nav"
              phx-value-page={@page - 1}
            >
              Anterior
            </a>
          <% else %>
            <span class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-300 cursor-not-allowed">
              Anterior
            </span>
          <% end %>

          <%= if @page < @total_pages do %>
            <a
              href="#"
            <a
              href="#"
              class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
              phx-click="nav"
              phx-click="nav"
              phx-value-page={@page + 1}
            >
              Próxima
            </a>
          <% else %>
            <span class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-300 cursor-not-allowed">
              Próxima
            </span>
          <% end %>
        </div>
        <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
          <div>
            <p class="text-sm text-gray-500">
              Mostrando <span class="font-medium"><%= min((@page - 1) * @per_page + 1, length(@orders)) %></span> a
              <span class="font-medium"><%= min(@page * @per_page, length(@orders)) %></span> de
              <span class="font-medium"><%= length(@orders) %></span> resultados
            </p>
          </div>
          <div>
            <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
              <%= if @page > 1 do %>
                <a
                  href="#"
                <a
                  href="#"
                  class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
                  phx-click="nav"
                  phx-click="nav"
                  phx-value-page={@page - 1}
                >
                  <span class="sr-only">Anterior</span>
                  <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
                  </svg>
                </a>
              <% else %>
                <span class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed">
                  <span class="sr-only">Anterior</span>
                  <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 01-.02 1.06L8.832 10l3.938 3.71a.75.75 0 11-1.04 1.08l-4.5-4.25a.75.75 0 010-1.08l4.5-4.25a.75.75 0 011.06.02z" clip-rule="evenodd" />
                  </svg>
                </span>
              <% end %>

              <%= for i <- max(1, @page - 2)..min(@total_pages, @page + 2) do %>
                <a
                  href="#"
                  class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if i == @page, do: "bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-white ring-1 ring-inset ring-gray-300 hover:bg-gray-50 hover:text-indigo-600 focus:outline-offset-0"}"}
                  phx-click="nav"
                  phx-value-page={i}
                >
                  <%= i %>
                </a>
              <% end %>

              <%= if @page < @total_pages do %>
                <a
                  href="#"
                <a
                  href="#"
                  class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
                  phx-click="nav"
                  phx-click="nav"
                  phx-value-page={@page + 1}
                >
                  <span class="sr-only">Próxima</span>
                  <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
                  </svg>
                </a>
              <% else %>
                <span class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-300 ring-1 ring-inset ring-gray-300 cursor-not-allowed">
                  <span class="sr-only">Próxima</span>
                  <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                    <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 01.02-1.06L11.168 10 7.23 6.29a.75.75 0 111.04-1.08l4.5 4.25a.75.75 0 010 1.08l-4.5 4.25a.75.75 0 01-1.06-.02z" clip-rule="evenodd" />
                  </svg>
                </span>
              <% end %>
            </nav>
          </div>
        </div>
      </nav>
    </div>
    """
  end
end
