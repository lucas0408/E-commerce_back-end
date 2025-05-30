defmodule BatchEcommerceWeb.Live.UserLive.FormComponent do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.CoreComponents  # Adicione esta linha
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Address

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-4xl mx-auto px-6 py-8">
        <.form
          :let={f}
          for={@form}
          id="user-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          class="space-y-6"
        >

          <div class="grid grid-cols-2 gap-6">
            <.input field={f[:name]} label="Nome" />
            <.input field={f[:cpf]} label="CPF" />

            <.input field={f[:email]} label="E-mail" type="email" />
            <.input field={f[:phone_number]} label="Telefone" />
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <.input field={f[:birth_date]} label="Data de Nascimento" type="date" />
          </div>

          <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
            <.input field={f[:password]} label="Senha" type="password" />
            <.input field={f[:password_confirmation]} label="Confirmar Senha" type="password" />
          </div>

          <.inputs_for :let={af} field={f[:addresses]}>
            <div class="mt-6 p-4 border rounded-lg space-y-4">
              <h4 class="font-semibold text-lg">Endereço</h4>

              <.input field={af[:cep]} label="CEP" />
              <.input field={af[:address]} label="Logradouro" />

              <div class="grid grid-cols-3 gap-4">
                <.input field={af[:home_number]} label="Número" />
                <.input field={af[:complement]} label="Complemento" />
              </div>

              <.input field={af[:district]} label="Bairro" />

              <div class="grid grid-cols-2 gap-4">
                <.input field={af[:city]} label="Cidade" />
                <.input field={af[:uf]} label="UF" class="uppercase" maxlength="2" />
              </div>
            </div>
          </.inputs_for>

          <div class="flex justify-center pt-6">
            <.button type="submit" class="bg-purple-600 hover:bg-purple-700 px-6 py-2 text-white font-semibold rounded-lg shadow-md">
              Cadastrar
            </.button>
          </div>
        </.form>
      </div>

    """
  end

  def update(%{user: user} = assigns, socket) do
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
    |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("add_address", _, socket) do
    changeset = socket.assigns.changeset
    current_addresses = changeset.changes[:addresses] || changeset.data.addresses || []
    new_address = %Address{}
    
    updated_changeset =
      changeset
      |> Ecto.Changeset.put_assoc(:addresses, current_addresses ++ [new_address])

    {:noreply, 
    socket
    |> assign(:changeset, updated_changeset)
    |> assign(:form, to_form(updated_changeset))}
  end

  @impl true
  def handle_event("remove_address", %{"index" => index}, socket) do
    index = String.to_integer(index)
    changeset = socket.assigns.changeset
    current_addresses = changeset.changes[:addresses] || changeset.data.addresses || []
    
    # Garante que não remove se só tem um endereço
    if length(current_addresses) > 1 do
      updated_addresses = List.delete_at(current_addresses, index)
      updated_changeset = Ecto.Changeset.put_assoc(changeset, :addresses, updated_addresses)

      {:noreply, 
      socket
      |> assign(:changeset, updated_changeset)
      |> assign(:form, to_form(updated_changeset))}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_user(socket, :new, user_params) do
    IO.inspect(user_params)
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "User created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = 
      socket.assigns.user
      |> Accounts.insert_change_user(user_params)
      |> Map.put(:action, :validate)
      
    {:noreply, 
    socket
    |> assign(:changeset, changeset)  # ✅ Adicionar esta linha
    |> assign(:form, to_form(changeset))}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
