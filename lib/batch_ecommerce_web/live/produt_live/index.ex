defmodule BatchEcommerceWeb.Live.ProductLive.Index do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog
  alias BatchEcommerceWeb.Live.ProductLive.FormComponent
  import BatchEcommerceWeb.CoreComponents
  alias BatchEcommerce.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)
    {:ok, 
      socket
      |> assign_defaults(current_user)
      |> load_products()
    }
  end

  defp assign_defaults(socket, current_user) do
    assign(socket, 
      categories: Catalog.list_categories(),
      selected_categories: [],
      search_query: "", 
      no_products_message: nil,
      page: 1,
      per_page: 10,
      products: [],
      meta: nil,
      current_user: current_user
    )
  end

  defp load_products(socket) do
    %{
      page: page, 
      per_page: per_page, 
      selected_categories: selected_categories,
      search_query: search_query
    } = socket.assigns

    %Scrivener.Page{entries: products, page_number: page_number, total_pages: total_pages} =
      Catalog.list_products_paginated(%{
        page: page,
        per_page: per_page,
        category_ids: selected_categories,
        search_query: search_query  # Adicione esta linha
      })

    assign(socket,
      products: products,
      meta: %{
        page_number: page_number,
        total_pages: total_pages
      },
      no_products_message: get_no_products_message(products, selected_categories, search_query)
    )
  end

  defp get_no_products_message(products, selected_categories, search_query) do
    cond do
      Enum.empty?(products) and not Enum.empty?(selected_categories) and search_query == "" ->
        "Nenhum produto encontrado com as categorias selecionadas"
      Enum.empty?(products) and search_query != "" ->
        "Nenhum produto encontrado para '#{search_query}'"
      Enum.empty?(products) ->
        "Nenhum produto encontrado"
      true ->
        nil
    end
  end

  @impl true
  def handle_event("toggle_category", %{"category" => category_id}, socket) do
    category_id = String.to_integer(category_id)

    selected_categories = 
      if category_id in socket.assigns.selected_categories do
        Enum.reject(socket.assigns.selected_categories, &(&1 == category_id))
      else
        [category_id | socket.assigns.selected_categories]
      end

    {:noreply, 
      socket
      |> assign(selected_categories: selected_categories, page: 1)
      |> load_products()
    }
  end

  @impl true
  def handle_event("redirect_to_product", %{"product-id" => product_id}, socket) do
    {:noreply, push_navigate(socket, to: "/products/#{product_id}")}
  end

  @impl true
  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply, 
      socket
      |> assign(page: String.to_integer(page))
      |> load_products()
    }
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, 
      socket
      |> assign(search_query: query, page: 1)
      |> load_products()
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component 
      module={BatchEcommerceWeb.Live.HeaderLive.HeaderFull} 
      id="header-full"
      user={@current_user}
      search_query={@search_query}  # Passa o estado atual da pesquisa
    />
    <div class="container mx-auto px-4 py-8">
      <div class="flex flex-col md:flex-row gap-8">
        <!-- Filtros de categoria (agora sticky) -->
        <.categories_sidebar 
          categories={@categories} 
          selected_categories={@selected_categories} 
        />

        <!-- Lista de produtos -->
        <div class="w-full md:w-3/4">
          <%= if @no_products_message do %>
            <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-4">
              <div class="flex">
                <div class="flex-shrink-0">
                  <svg class="h-5 w-5 text-yellow-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                    <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                  </svg>
                </div>
                <div class="ml-3">
                  <p class="text-sm text-yellow-700">
                    <%= @no_products_message %>
                  </p>
                </div>
              </div>
            </div>
          <% end %>

          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
            <%= for product <- @products do %>
              <.product_card product={product} />
            <% end %>
          </div>

          <!-- Paginação -->
          <%= if @meta && @meta.total_pages > 1 do %>
            <div class="mt-8 flex justify-center">
              <nav class="inline-flex rounded-md shadow">
                <%= for page <- 1..@meta.total_pages do %>
                  <button
                    phx-click="paginate"
                    phx-value-page={page}
                    class={"px-4 py-2 border #{if page == @meta.page_number, do: "bg-indigo-600 text-white", else: "bg-white text-gray-700 hover:bg-gray-50"}"}
                  >
                    <%= page %>
                  </button>
                <% end %>
              </nav>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end