defmodule BatchEcommerceWeb.Live.CompanyLive.ProductIndex do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Accounts

  @per_page 4

  @impl true
  def mount(%{"company_id" => company_id}, _session, socket) do
    {:ok, 
     socket
     |> assign(:company_id, company_id)
     |> assign(:products, [])
     |> assign(:search_term, "")
     |> assign(:page, 1)
     |> assign(:per_page, @per_page)  # Adicionamos ao socket
     |> assign(:total_pages, 1)
     |> assign(:export_form, to_form(%{"format" => "csv"}))
     |> load_products()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    page = params |> Map.get("page", "1") |> String.to_integer()
    search_term = params |> Map.get("search", "")
    
    {:noreply, 
    socket
    |> assign(:page, page)
    |> assign(:search_term, search_term)
    |> load_products()}
  end

  defp load_products(socket) do
    %{search_term: term, page: page, company_id: company_id, per_page: per_page} = socket.assigns
    
    %{entries: entries, total_pages: total_pages, total_entries: total_entries} = 
      Catalog.list_company_products_paginated(company_id, term, page, per_page)

    socket
    |> assign(:products, entries)
    |> assign(:total_pages, total_pages)
    |> assign(:total_entries, total_entries)
  end

  @impl true
  def handle_event("search", %{"search_term" => term}, socket) do
    {:noreply,
    push_patch(socket,
      to: ~p"/companies/#{socket.assigns.company_id}/products?search=#{term}&page=1",
      replace: true
    )}
  end

  @impl true
  def handle_event("nav", %{"page" => page}, socket) do
    page = String.to_integer(page)
    {:noreply,
     socket
     |> assign(:page, page)
     |> load_products()}
  end

  @impl true
  def handle_event("export", %{"format" => format}, socket) do
    {:noreply, put_flash(socket, :info, "Exportando relatório em #{format}...")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 py-8">
      <.header>
        Produtos da Empresa
        <:subtitle>Gerenciamento completo dos produtos</:subtitle>
      </.header>

      <!-- Barra de pesquisa e botões -->
      <div class="flex justify-between items-center mb-6">
      <.simple_form 
        for={%{}} 
        as={:search} 
        phx-change="search" 
        phx-submit="search" 
        class="flex items-center space-x-4"
      >
        <.input
          type="text"
          name="search_term"
          value={@search_term}
          placeholder="Pesquisar por nome..."
          class="w-64"
          phx-debounce="300"
        />
        <button type="submit" class="hidden">Buscar</button>
      </.simple_form>

        <div class="flex space-x-3">
          <a href={~p"/api/orders/export-stream"} 
            class="btn btn-primary"
            download>
            Exportar relatório
          </a>
          <.link patch={~p"/companies/#{@company_id}/products/new"} color="primary">
            Adicionar Produto
          </.link>
        </div>
      </div>

      <!-- Formulário de exportação -->
      <.form :let={f} for={@export_form} id="export-form" phx-submit="export">
        <.input type="hidden" field={f[:format]} value="csv" />
      </.form>

      <!-- Tabela de produtos -->
      <.table id="products" rows={@products}>
        <:col :let={product} label="Nome">
          <%= product.name %>
        </:col>
        <:col :let={product} label="Vendas">
          <%= product.sales_quantity %>
        </:col>
        <:col :let={product} label="Em Carrinhos">
          <%= product.stock_quantity %>
        </:col>
        <:col :let={product} label="Classificação">
          <%= product.rating %>/5
        </:col>
        <:col :let={product} label="Preço">
          <%= product.price %>
        </:col>
        <:col :let={product} label="Ações">
          <.link 
            patch={~p"/products/#{product.id}/edit"} 
            class="text-blue-600 hover:text-blue-800"
          >
            Editar
          </.link>
        </:col>
      </.table>

      <!-- Paginação corrigida -->
 <!-- Paginação corrigida -->
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