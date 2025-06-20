defmodule BatchEcommerceWeb.Live.CompanyLive.OrderIndex do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Orders
  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Accounts

  @per_page 4

  @impl true
  def mount(%{"company_id" => company_id}, _session, socket) do

    {:ok, 
     socket
     |> assign(:company_id, company_id)
     |> assign(:orders, [])
     |> assign(:page, 1)
     |> assign(:per_page, @per_page)
     |> assign(:total_pages, 1)
     |> assign(:user, %{name: "ricardo", id: 1})
     |> load_orders()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = params |> Map.get("page", "1") |> String.to_integer()
    {:noreply, socket |> assign(:page, page) |> load_orders()}
  end

  defp load_orders(socket) do
    %{company_id: company_id, page: page, per_page: per_page} = socket.assigns
    
    %{entries: orders, total_pages: total_pages} = 
      Orders.list_company_orders_paginated(company_id, page, per_page)
    IO.inspect(Orders.list_orders, label: "orders list")
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
  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} id="HeaderDefault"/>
    <div class="max-w-7xl mx-auto px-4 py-8">
    
    <!-- Tabela de pedidos -->
    <div class="mt-8 flow-root">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <table class="min-w-full divide-y divide-gray-300">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0">Produto</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Cliente</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Quantidade</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Total</th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Ação</th>
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
                        <img class="h-11 w-11 rounded-full" src={order_product.product.image_url} alt={order_product.product.name}>
                      </div>
                      <div class="ml-4">
                        <div class="font-medium text-gray-900"><%= order_product.product.name %></div>
                      </div>
                    </div>
                  </td>
                  <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                    <div class="text-gray-900"><%= order_product.order.user.name %></div>
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
              class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
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
              class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
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
            <p class="text-sm text-gray-700">
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
                  class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
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
                  class={"relative inline-flex items-center px-4 py-2 text-sm font-semibold #{if i == @page, do: "bg-indigo-600 text-white focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600", else: "text-gray-900 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:outline-offset-0"}"}
                  phx-click="nav" 
                  phx-value-page={i}
                >
                  <%= i %>
                </a>
              <% end %>

              <%= if @page < @total_pages do %>
                <a 
                  href="#" 
                  class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
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