defmodule BatchEcommerceWeb.Live.ProductLive.New do
  use BatchEcommerceWeb, :live_view
  alias BatchEcommerce.Catalog.Product
  alias BatchEcommerceWeb.Live.ProductLive.FormComponent
  alias BatchEcommerce.Accounts
  alias BatchEcommerce.Accounts.User

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id")

    current_user = Accounts.get_user(user_id)

    case Accounts.user_preload_company(current_user) do
      %User{company: nil} ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/companies/new")}

      %User{company: company} ->
        {:ok,
        socket
        |> assign(:current_user, current_user)
        |> assign(:company, company)
        |> assign(:page_title, "Nova Empresa")}
    end
  end

  def render(assigns) do
    ~H"""
    <.live_component module={BatchEcommerceWeb.Live.HeaderLive.HeaderDefault} user={@current_user} company={@current_company} id="HeaderDefault"/>
    <div class="px-4">
      <.live_component
        module={FormComponent}
        id="new-product"
        product={%Product{}}
        action={@live_action}
        company_id={@company.id}
      >
        <h1 class="text-2xl font-bold mb-4">Creating a product</h1>
      </.live_component>

      <.back navigate={~p"/products"}>
        Back to products
      </.back>
    </div>
    """
  end
end
