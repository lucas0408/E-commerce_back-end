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
    <div class="px-[150px] py-[75px] my-10 mx-[225px] rounded-3xl bg-white">

      <!-- Informações básicas -->
      <div class="space-y-4 mb-10">
        <div class="grid grid-cols-2 gap-20">
          <.field_display label="Nome" value={@user.name} />
          <.field_display label="CPF" value={@user.cpf} />
        </div>
        <div class="grid grid-cols-2 gap-20">
          <.field_display label="Email" value={@user.email} />
          <.field_display label="Telefone" value={@user.phone_number} />
        </div>
      </div>

      <!-- Lista de endereços -->
      <div class="space-y-6">
        <h2 class="text-lg font-medium text-gray-900">Endereços Cadastrados</h2>

        <%= for address <- @user.addresses do %>
          <div class="space-y-4 p-4 border rounded-lg">
            <div class="grid grid-cols-2 gap-20">
              <.field_display label="Rua" value={address.address} />
              <.field_display label="Número" value={address.home_number} />
            </div>

            <div class="grid grid-cols-2 gap-20">
              <.field_display label="Cidade" value={address.city} />
              <.field_display label="Estado" value={address.uf} />
            </div>
            <div class="max-w-[125px]">
              <.field_display label="CEP" value={address.cep} />
            </div>
          </div>
        <% end %>
      </div>

      <!-- Botões de ação -->
      <div class="mt-4 px-[350px]">

        <.link
          patch={~p"/users/#{@user}/addresses/new"}
          class="block w-full w-full mb-3 text-center py-2 bg-gray-50 hover:scale-105 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-200"
        >
          Adicionar Novo Endereço
        </.link>

        <.link
          patch={~p"/users/#{@user}/edit"}
          class="block w-full text-center py-2 px-4 border hover:scale-105 border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-800"
        >
          Alterar Dados Pessoais
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
