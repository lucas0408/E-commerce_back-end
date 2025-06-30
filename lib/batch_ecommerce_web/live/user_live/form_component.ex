defmodule BatchEcommerceWeb.Live.UserLive.FormComponent do
  use BatchEcommerceWeb, :live_component

  import BatchEcommerceWeb.CoreComponents

  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Address

  @ufs ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA",
    "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN",
    "RS", "RO", "RR", "SC", "SP", "SE", "TO"]

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-5xl mx-auto">
        <.form
          :let={f}
          for={@form}
          id="user-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          class="space-y-5"
        >

          <div class="grid grid-cols-2 gap-x-20 gap-y-6">
            <.input field={f[:name]} label="Nome"/>
            <.input field={f[:cpf]} label="CPF" disabled={@action == :edit} phx-hook="CpfMask"/>
            <.input field={f[:email]} label="E-mail" type="email" disabled={@action == :edit}/>
            <.input field={f[:phone_number]} label="Telefone" disabled={@action == :edit} phx-hook="PhoneMask"/>
          </div>

          <div class="grid grid-cols-2 gap-x-20 gap-y-6">
            <%= if @action == :new do %>
              <div class="grid grid-cols-1 max-w-[275px] gap-6">
                <.input field={f[:password]} label="Senha" type="password" disabled={@action == :edit}/>
                <.input field={f[:password_confirmation]} label="Confirmar Senha" type="password" disabled={@action == :edit}/>
              </div>
            <% end %>

          <div class="grid grid-cols-1 max-w-[170px] gap-6">
            <.input field={f[:birth_date]} label="Data de Nascimento" type="date" disabled={@action == :edit}/>
          </div>
        </div>

          <.inputs_for :let={af} field={f[:addresses]}>
            <div>
              <div class="grid grid-cols-2 gap-x-20 gap-y-6">
                <.input field={af[:address]} label="Endereço" />
                <div class="flex gap-6">
                  <div class="max-w-[85px]">
                    <.input field={af[:home_number]} label="Número" />
                  </div>
                  <.input field={af[:cep]} label="CEP" phx-hook="CepMask"/>
                </div>
                  <.input field={af[:complement]} label="Complemento" />
                  <.input field={af[:district]} label="Bairro" />
                <div class="flex gap-4">
                  <.input field={af[:city]} label="Cidade" />
                  <div class="max-w-[100px]">
                    <.input
                      field={af[:uf]}
                      label="Estado"
                      type="select"
                      options={@ufs}
                      class="uppercase"
                      prompt="Selecione"
                    />
                  </div>
                </div>
              </div>
            </div>
          </.inputs_for>
          <p> Adicione sua foto de perfil </p>
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

          <div class="flex justify-center pt-6">
            <.button type="submit" class="bg-indigo-600 min-w-[300px] hover:bg-indigo-800 px-6 py-2 text-white font-semibold rounded-lg shadow-md">
              <%= case @action do %>
                <% :edit -> %>Atualizar Cadastro
                <% :new -> %>Cadastrar
              <% end %>
            </.button>
          </div>
        </.form>
      </div>
    """
  end

  @impl true
  def update(%{user: user, action: action} = assigns, socket) do
    user_with_addresses =
      if Ecto.assoc_loaded?(user.addresses) and not Enum.empty?(user.addresses) do
        user
      else
        %{user | addresses: [%Address{}]}
      end

    changeset = Accounts.insert_change_user(user_with_addresses)

    {:ok,
    socket
    |> assign(assigns)
    |> assign(:changeset, changeset)
    |> assign(:action, action)
    |> assign(:ufs, @ufs)
    |> assign(:form, to_form(changeset))
    |> allow_upload(:image,
      accept: ~w(.jpg .jpeg .png .gif),
      max_entries: 1,
      max_file_size: 5_000_000
    )}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.form_change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply,
    socket
    |> assign(:changeset, changeset)
    |> assign(:form, to_form(changeset))}
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Conta atualizada com sucesso")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    pre_filename = Accounts.normalize_filename(user_params["name"])

    with {:ok, filename} <- Accounts.upload_image(socket, pre_filename, :user),
    updated_params = Map.put(user_params, "profile_filename", filename),
    {:ok, user} <- Accounts.create_user(updated_params) do
      notify_parent({:saved, user})

      {:noreply,
        socket
        |> put_flash(:info, "Conta criada com sucesso")
        |> push_navigate(to: socket.assigns.patch)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp error_to_string(:too_large), do: "Arquivo muito grande (máximo 5MB)"
  defp error_to_string(:not_accepted), do: "Tipo de arquivo não aceito"
  defp error_to_string(:too_many_files), do: "Muitos arquivos (máximo 1)"

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
