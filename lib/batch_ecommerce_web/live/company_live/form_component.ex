defmodule BatchEcommerceWeb.Live.CompanyLive.FormComponent do
  use BatchEcommerceWeb, :live_component
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.Company
  alias BatchEcommerce.Accounts.Address

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-6 py-8">
      <.form
        :let={f}
        for={@form}
        id="company-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="grid grid-cols-2 gap-6"
      >
        <!-- Linha 1: nome e CNPJ -->
        <.input field={@form[:name]} type="text" label="Nome" />
        
        <!-- Só mostra CNPJ se for uma criação nova -->
        <%= if @action == :new do %>
          <.input field={@form[:cnpj]} type="text" label="CNPJ" />
        <% else %>
          <!-- Opcional: Mostrar o CNPJ como texto se for edição -->
          <div class="flex flex-col">
            <label class="block text-sm font-medium text-gray-700">CNPJ</label>
            <div class="mt-1 text-gray-900">
              <%= @company.cnpj %>
            </div>
          </div>
        <% end %>

        <!-- Restante do seu formulário... -->
        <!-- Linha 2: email e telefone -->
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:phone_number]} type="text" label="Telefone" />

        <!-- Campos de endereço -->
        <.inputs_for :let={af} field={@form[:addresses]}>
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
        </.inputs_for>

        <!-- Botão de cadastro -->
        <div class="col-span-2 flex justify-center mt-4">
          <.button class="bg-blue-600 text-white px-6 py-2 rounded">
            <%= if @action == :new, do: "Cadastrar Empresa", else: "Atualizar Empresa" %>
          </.button>
        </div>
      </.form>
    </div>
    """
  end


  def update(%{company: company} = assigns, socket) do
    IO.inspect(socket)
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
    save_company(socket, socket.assigns.action, company_params)
  end

  defp save_company(socket, :edit, company_params) do
      IO.inspect(company_params)
    case Accounts.update_company(socket.assigns.company, company_params) do
      {:ok, company} ->
        notify_parent({:saved, company})

        {:noreply,
         socket
         |> put_flash(:info, "company updated successfully")
         |> push_patch(to: socket.assigns.patch)}

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
        IO.inspect(company)

        {:noreply,
         socket
         |> put_flash(:info, "company created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"company" => company_params}, socket) do
    changeset = 
      socket.assigns.company
      |> Accounts.change_company(company_params)
      |> Map.put(:action, :validate)
      
    {:noreply, 
    socket
    |> assign(:changeset, changeset)  # ✅ Adicionar esta linha
    |> assign(:form, to_form(changeset))}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})



end