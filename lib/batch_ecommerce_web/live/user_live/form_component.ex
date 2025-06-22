defmodule BatchEcommerceWeb.Live.UserLive.FormComponent do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.CoreComponents  
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Address

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-6xl mx-auto">
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
            <.input field={f[:name]} label="Nome" />
            <.input field={f[:cpf]} label="CPF" />

            <.input field={f[:email]} label="E-mail" type="email" />
            <.input field={f[:phone_number]} label="Telefone" />
          </div>

          <div class="grid grid-cols-2 gap-x-20 gap-y-6">
            <div class="grid grid-cols-1 max-w-[275px] gap-6">
                <.input field={f[:password]} label="Senha" type="password" />
                <.input field={f[:password_confirmation]} label="Confirmar Senha" type="password" />

              </div>

            <div class="grid grid-cols-1 max-w-[170px] gap-6">
              <.input field={f[:birth_date]} label="Data de Nascimento" type="date" />
            </div>
          </div>

          <.inputs_for :let={af} field={f[:addresses]}>
            <div class="mt-6 p-4 border rounded-lg space-y-4">
              <h4 class="font-semibold text-lg">Endereço</h4>

              <div class="grid grid-cols-2 gap-x-20 gap-y-6">

                <.input field={af[:address]} label="Endereço" />

                <div class="flex gap-6">
                  <div class="max-w-[85px]">
                    <.input field={af[:home_number]} label="Número" />
                  </div>
                  <.input field={af[:cep]} label="CEP" />
                </div>

                  <.input field={af[:complement]} label="Complemento" />
                  <.input field={af[:district]} label="Bairro" />

                <div class="flex gap-4">
                  <.input field={af[:city]} label="Cidade" />
                  <div class="max-w-[50px]">
                    <.input field={af[:uf]} label="Estado" class="uppercase" maxlength="2" />
                  </div>
                </div>
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
         |> push_navigate(to: socket.assigns.patch)}

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
         |> push_navigate(to: socket.assigns.patch)}

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
