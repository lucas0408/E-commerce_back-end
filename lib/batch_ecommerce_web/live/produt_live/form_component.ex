defmodule BatchEcommerceWeb.Live.ProductLive.FormComponent do
  use BatchEcommerceWeb, :live_component
  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.Category
  alias BatchEcommerce.Catalog.Product

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)
    categories = Catalog.list_categories()
    {selected_categories, preco_total} = if assigns.action == :edit do
      {Enum.map(product.categories, &to_string(&1.id)),
       calculate_total_price(Decimal.to_float(product.price), Decimal.to_float(product.discount))}
    else
      {[], 0}
    end
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))
     |> assign(:changeset, changeset)
     |> assign(:categories, categories)
     |> assign(:selected_categories, selected_categories)
     |> assign(:uploaded_files, [])
     |> assign(:preco_total, preco_total)
     |> allow_upload(:image, 
         accept: ~w(.jpg .jpeg .png .gif),
         max_entries: 1,
         max_file_size: 5_000_000
       )}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    preco = parse_decimal(product_params["price"] || "0")
    desconto = parse_decimal(product_params["discount"] || "0")
    preco_total = calculate_total_price(preco, desconto)

    new_selected = Map.get(product_params, "categories", [])
    previous_selected = socket.assigns.selected_categories

    selected_categories = Enum.uniq(previous_selected ++ new_selected)

    

    changeset =
      %Product{}
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply,
    socket
    |> assign(:form, to_form(changeset))
    |> assign(:selected_categories, selected_categories)
    |> assign(:preco_total, preco_total)}
  end


  @impl true
  def handle_event("save", %{"product" => product_params}, socket) do
    # Garantir que categories está presente nos parâmetros
    product_params_with_categories = 
      product_params
      |> Map.put("category_ids", socket.assigns.selected_categories)
      |> Map.put("company_id", socket.assigns.company_id)

    case socket.assigns.action do
      :edit ->
        update_product(socket, product_params_with_categories)
      :new ->
        create_product(socket, product_params_with_categories)
    end
  end

  defp create_product(socket, product_params) do
    product_params_with_rating = product_params |> Map.put("rating", 4)

    case Catalog.create_product(product_params_with_rating) do
      {:ok, product} ->
        notify_parent({:saved, product})
        {:noreply,
         socket
         |> put_flash(:info, "Produto criado com sucesso")
        |> push_redirect(to: ~p"/companies/#{socket.assigns.company_id}/products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Changeset Error")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_product(socket, product_params) do
    case Catalog.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:updated, product})
        {:noreply,
         socket
         |> put_flash(:info, "Produto atualizado com sucesso")
         |> push_redirect(to: ~p"/companies/#{socket.assigns.company_id}/products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Changeset Error")
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-6">
      <div class="bg-white shadow-lg rounded-lg p-8 ">
        <h1 class="text-4xl font-bold text-gray-800 mb-8 text-center">
          Cadastro de Produto
        </h1>

        <.form
          :let={f}
          for={@form}
          id="product-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          class="space-y-6"
        >
        
          <!-- Linha 1: Nome e Categoria -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-[150px]">
            <div class="grid gap-6">
              <.input
                field={f[:name]}
                type="text"
                label="Nome"
                placeholder="Digite o nome do produto"
                required
              />
              <!-- Linha 2: Preço e Desconto -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-10">
                <div>
                  <.input
                    field={f[:price]}
                    type="number"
                    label="Preço (R$)"
                    step="0.01"
                    min="0"
                    inputmode="decimal"
                    placeholder="0.00"
                    value={to_string(f[:price].value || "")}
                  />
                </div>

                <div>
                  <.input
                    field={@form[:discount]}
                    type="number"
                    label="Desconto (%)"
                    min="0"
                    max="100"
                    inputmode="decimal"
                    placeholder="0.00"
                    value={to_string(@form[:discount].value || "")}
                    class="w-full px-4 py-2 border-2 border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <div class="w-full px-4 py-2 my-2 bg-white border-2 border-gray-300 rounded-md text-gray-700 font-semibold">
                    <%= if @preco_total do %>
                      Total: R$ {@preco_total}
                    <% else %>
                      Total: R$ 0.00
                    <% end %>
                  </div>
                </div>

                <div>
                  <.input
                    field={f[:stock_quantity]}
                    type="number"
                    label="Estoque"
                    min="0"
                    inputmode="numeric"
                    placeholder="0"
                    value={to_string(f[:stock_quantity].value || "")}
                  />
                </div>
              </div>

              <!-- Linha 3: Descrição -->
              <div>
                <.input
                  field={f[:description]}
                  type="textarea"
                  rows="4"
                  placeholder="Digite uma descrição detalhada do produto"
                  class="w-full px-4 py-2 border-2 border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-none"
                />
              </div>
            </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <.input
                field={@form[:name]}
                type="text"
                label="Nome"
                placeholder="Digite o nome do produto"
                required
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Categorias *
              </label>
              <select
                name="product[categories][]"
                multiple
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500 h-32"
                style="min-height: 120px;"
              >
                <%= for category <- @categories do %>
                  <option 
                    value={category.id}
                    selected={to_string(category.id) in @selected_categories}
                  >
                    <%= category.type %>
                  </option>
                <% end %>
              </select>
            </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Categorias Selecionadas
                </label>
                <div class="flex flex-wrap gap-2">
                  <%= for category_id <- @selected_categories do %>
                    <% category = Enum.find(@categories, &(to_string(&1.id) == category_id)) %>
                    <%= if category do %>
                      <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                        <%= category.type %>
                      </span>
                    <% end %>
                  <% end %>
                </div>
              </div>

              <!-- Upload de Imagem -->
              <div>
                <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 bg-gray-50">
                  <div class="text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                      <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>

                    <div class="mt-2">
                      <label for={@uploads.image.ref} class="cursor-pointer">
                        <span class="mt-2 block text-sm font-medium text-gray-900">
                          Clique para adicionar imagem
                        </span>
                        <span class="mt-1 block text-xs text-gray-500">
                          PNG, JPG, GIF até 5MB
                        </span>
                      </label>
                      <.live_file_input upload={@uploads.image} class="sr-only" />
                    </div>
                  </div>

                  <!-- Preview das imagens -->
                  <%= for entry <- @uploads.image.entries do %>
                    <div class="mt-4 flex items-center justify-between bg-white p-2 rounded border">
                      <div class="flex items-center gap-3">
                        <!-- Aspect Ratio 4:3 -->
                        <div class="w-28 aspect-w-4 aspect-h-3">
                          <.live_img_preview entry={entry} class="w-full h-full object-cover rounded" />
                        </div>
                        <div>
                          <p class="text-sm font-medium text-gray-900"><%= entry.client_name %></p>
                          <p class="text-xs text-gray-500"><%= trunc(entry.progress) %>% carregado</p>
                        </div>
                      </div>
                      <button
                        type="button"
                        phx-click="cancel-upload"
                        phx-value-ref={entry.ref}
                        phx-target={@myself}
                        class="text-red-600 hover:text-red-800"
                      >
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                      </button>
                    </div>
                  <% end %>

                  <!-- Erros de upload -->
                  <%= for err <- upload_errors(@uploads.image) do %>
                    <div class="mt-2 text-sm text-red-600">
                      <%= error_to_string(err) %>
                    </div>
                  <% end %>
                </div>
              </div>

              <!-- Botão de Submissão -->
              <div class="flex justify-center pt-6">
                <button
                  type="submit"
                  class="px-8 py-3 bg-blue-600 text-white font-semibold rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition duration-200"
                >
                  Adicionar Produto
                </button>
              </div>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  # Funções auxiliares
  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, _} -> Decimal.to_float(decimal)
      :error -> 0.0
    end
  end

  defp parse_decimal(value) when is_number(value), do: value
  defp parse_decimal(_), do: 0.0

  defp calculate_total_price(preco, desconto) do
    total = if desconto > 0 do
      preco * (1 - desconto / 100)
    else
      preco
    end
    total
    |> Decimal.from_float()
    |> Decimal.round(2)
    |> Decimal.to_float()
  end

  defp error_to_string(:too_large), do: "Arquivo muito grande (máximo 5MB)"
  defp error_to_string(:not_accepted), do: "Tipo de arquivo não aceito"
  defp error_to_string(:too_many_files), do: "Muitos arquivos (máximo 1)"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end