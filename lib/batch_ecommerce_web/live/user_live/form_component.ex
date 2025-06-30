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
    |> assign(:form, to_form(changeset))}
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
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, "Conta criada com sucesso")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
