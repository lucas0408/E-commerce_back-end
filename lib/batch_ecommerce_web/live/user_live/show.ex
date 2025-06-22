defmodule BatchEcommerceWeb.Live.UserLive.Show do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts
  import BatchEcommerceWeb.CoreComponents

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Accounts.get_user(id) 
    {:ok, assign(socket, user: user)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@user} id="HeaderDefault"/>
    <div class="pt-10 px-4">

      <!-- Informações básicas -->
      <div class="space-y-4">
        <.field_display label="Nome" value={@user.name} />
        <.field_display label="Email" value={@user.email} />
        
        <div class="grid grid-cols-2 gap-4">
          <.field_display label="CPF" value={@user.cpf} />
          <.field_display label="Telefone" value={@user.phone_number} />
        </div>
      </div>

      <!-- Lista de endereços -->
      <div class="space-y-6">
        <h2 class="text-lg font-medium text-gray-900">Endereços Cadastrados</h2>
        
        <%= for address <- @user.addresses do %>
          <div class="space-y-4 p-4 border rounded-lg">
            <div class="grid grid-cols-2 gap-4">
              <.field_display label="Rua" value={address.address} />
              <.field_display label="Número" value={address.home_number} />
            </div>
            
            <div class="grid grid-cols-2 gap-4">
              <.field_display label="Cidade" value={address.city} />
              <.field_display label="Estado" value={address.uf} />
            </div>
            
            <.field_display label="CEP" value={address.cep} />
            
          </div>
        <% end %>
      </div>

      <!-- Botões de ação -->
      <div class="space-y-2 pt-4">
        <.link 
          patch={~p"/users/#{@user}/edit"}
          class="block w-full text-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
        >
          Alterar Dados Pessoais
        </.link>
        
        <.link 
          patch={~p"/users/#{@user}/addresses/new"}
          class="block w-full text-center py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
        >
          Adicionar Novo Endereço
        </.link>
      </div>
    </div>
    """
  end

  defp field_display(assigns) do
    ~H"""
    <div>
      <label class="block text-sm font-medium text-gray-700"><%= @label %></label>
      <div class="mt-1 p-2 border-b border-gray-300">
        <%= if @value do %>
          <%= @value %>
        <% else %>
          <span class="text-gray-400">Não informado</span>
        <% end %>
      </div>
    </div>
    """
  end
end