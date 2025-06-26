defmodule BatchEcommerceWeb.Live.AddressLive.Form do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Accounts.Address
  alias BatchEcommerce.Accounts

  @ufs ["AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", 
        "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", 
        "RS", "RO", "RR", "SC", "SP", "SE", "TO"]

  @impl true
  def mount(_params, session, socket) do
    user_id = Map.get(session, "current_user")
    current_user = Accounts.get_user(user_id)
    uf_options = Enum.map(@ufs, &{&1, &1})
    
    {:ok, 
     socket
     |> assign(:uf_options, uf_options)
     |> assign(:current_user, current_user)
     |> assign(:changeset, Accounts.change_address(%Address{}))
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"address" => address_params}, socket) do
    changeset =
      %Address{}
      |> Accounts.change_address(address_params)
      |> Map.put(:action, :validate)

    {:noreply, 
     socket
     |> assign(:changeset, changeset)
     |> assign_form()}
  end

  def handle_event("save", %{"address" => address_params}, socket) do
    %{current_user: user} = socket.assigns

    address_changeset = Accounts.change_address(%Address{}, address_params)

    user_params = %{
      "addresses" => [address_changeset.changes | Enum.map(user.addresses, &Map.from_struct/1)]
    }

    case Accounts.update_user(user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Endereço cadastrado com sucesso")
         |> push_navigate(to: "/cart_products")}

      {:error, %Ecto.Changeset{} = changeset} ->
        # Extrai o changeset do endereço dos erros se necessário
        address_changeset = 
          case changeset.changes[:addresses] do
            [%Ecto.Changeset{} = addr_changeset] -> addr_changeset
            _ -> Address.changeset(%Address{}, address_params)
          end

        {:noreply, 
         socket
         |> assign(:changeset, address_changeset)
         |> assign_form()}
    end
  end

  defp assign_form(socket) do
    assign(socket, :form, to_form(socket.assigns.changeset))
  end
end