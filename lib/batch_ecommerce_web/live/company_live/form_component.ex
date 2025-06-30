defmodule BatchEcommerceWeb.Live.CompanyLive.FormComponent do
  use BatchEcommerceWeb, :live_component

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Address

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto">
      <.form
        for={@form}
        id="company-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="grid grid-cols-2 gap-x-20 gap-y-7">
          <!-- Linha 1: nome e CNPJ -->
          <.input field={@form[:name]} type="text" label="Nome" />

          <%= if @action == :new do %>
            <.input field={@form[:cnpj]} type="text" label="CNPJ" phx-hook="CnpjMask" />
          <% else %>
            <div class="flex flex-col">
              <label class="block text-sm font-medium text-gray-700">CNPJ</label>
              <div class="mt-1 text-gray-900">
                <%= @company.cnpj %>
              </div>
            </div>
          <% end %>

          <!-- Linha 2: email e telefone -->
          <.input field={@form[:email]} type="email" label="Email" />
          <.input field={@form[:phone_number]} type="text" label="Telefone" phx-hook="PhoneMask" />

          <!-- Campos de endereço -->
          <.inputs_for :let={af} field={@form[:addresses]}>
            <.input field={af[:address]} label="Rua" />
            <div class="flex gap-4">
              <div class="max-w-[85px]">
                <.input field={af[:home_number]} label="Número"/>
              </div>
              <.input field={af[:cep]} label="CEP" phx-hook="CepMask"/>
            </div>
            <.input field={af[:complement]} label="Complemento" />
            <.input field={af[:district]} label="Bairro" />
            <div class="flex gap-4">
              <.input field={af[:city]} label="Cidade" />
              <div class="max-w-[50px]">
                <.input field={af[:uf]} label="Estado" class="uppercase text-center" maxlength="2" />
              </div>
            </div>
          </.inputs_for>
        </div>

        <p> Adicione a foto de perfil da sua empresa </p>
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

        <!-- Botão dinâmico -->
        <div class="col-span-2 flex justify-center mt-10">
          <.button class="bg-indigo-600 hover:bg-indigo-800 text-white px-6 py-2 rounded">
            <%= if @action == :new, do: "Cadastrar Empresa", else: "Salvar Empresa" %>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def update(%{company: company} = assigns, socket) do
    company =
      if Ecto.assoc_loaded?(company.addresses) and not Enum.empty?(company.addresses) do
        company
      else
        %{company | addresses: [%Address{}]}
      end

    changeset = Accounts.change_company(company)

    {:ok,
    socket
    |> assign(assigns)
    |> assign(:changeset, changeset)
    |> assign(:form, to_form(changeset))
    |> allow_upload(:image,
      accept: ~w(.jpg .jpeg .png .gif),
      max_entries: 1,
      max_file_size: 5_000_000
    )}
  end

  @impl true
  def handle_event("save", %{"company" => company_params}, socket) do
    save_company(socket, socket.assigns.action, company_params)
  end

  @impl true
  def handle_event("validate", %{"company" => company_params}, socket) do
    changeset =
      socket.assigns.company
      |> Accounts.change_company(company_params)
      |> Map.put(:action, :validate)

    {:noreply,
    socket
    |> assign(:changeset, changeset)
    |> assign(:form, to_form(changeset))}
  end

  defp save_company(socket, :edit, company_params) do
    case Accounts.update_company(socket.assigns.company, company_params) do
      {:ok, company} ->
        notify_parent({:saved, company})

        {:noreply,
         socket
         |> put_flash(:info, "Empresa atualizada com sucesso")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_company(socket, :new, company_params) do
    company_params =
     company_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    pre_filename = Accounts.normalize_filename(company_params["name"])

    with {:ok, filename} <- Accounts.upload_image(socket, pre_filename, :company),
      updated_params = Map.put(company_params, "profile_filename", filename),
      {:ok, company} <- Accounts.create_company(updated_params) do
        notify_parent({:saved, company})

        {:noreply,
         socket
         |> put_flash(:info, "Empresa criada com sucesso")
         |> push_navigate(to: socket.assigns.patch)}

      else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
      {:error, _any} ->
        {:noreply,
        socket
        |> put_flash(:warning, "Error to conect with Minio")
        |> push_navigate(to: socket.assigns.patch)}
    end
  end

  defp error_to_string(:too_large), do: "Arquivo muito grande (máximo 5MB)"
  defp error_to_string(:not_accepted), do: "Tipo de arquivo não aceito"
  defp error_to_string(:too_many_files), do: "Muitos arquivos (máximo 1)"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
