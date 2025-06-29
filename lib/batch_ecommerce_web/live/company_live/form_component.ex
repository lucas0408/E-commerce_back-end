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
            <.input field={@form[:cnpj]} type="text" label="CNPJ" />
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
          <.input field={@form[:phone_number]} type="text" label="Telefone" />

          <!-- Campos de endereço -->
          <.inputs_for :let={af} field={@form[:addresses]}>
            <.input field={af[:address]} label="Rua" />
            <div class="flex gap-4">
              <div class="max-w-[85px]">
                <.input field={af[:home_number]} label="Número"/>
              </div>
              <.input field={af[:cep]} label="CEP" />
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
    |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"company" => company_params}, socket) do
    IO.puts("ou ta vindo pra ca")
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
         |> put_flash(:info, "company updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_company(socket, :new, company_params) do
    company_params =
     company_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Accounts.create_company(company_params) do
      {:ok, company} ->
        notify_parent({:saved, company})

        {:noreply,
         socket
         |> put_flash(:info, "company created successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
      {:error, _any} ->
        {:noreply,
        socket
        |> put_flash(:warning, "Error to conect with Minio")
        |> push_navigate(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
