defmodule BatchEcommerceWeb.Live.HeaderLive.HeaderWithSearch do
  use BatchEcommerceWeb, :live_component

  def render(assigns) do
    assigns =
      assigns
      |> assign(:show_cart, false)
      |> assign(:show_search, true)
      |> assign(:show_menu, false)
      |> assign_new(:notification_count, fn -> 0 end)
      |> assign_new(:cart_count, fn -> 0 end)
      |> assign_new(:user, fn -> nil end)
      # Remove a assign de search_query pois será gerenciado pelo ProductLive.Index

    ~H"""
    <div>
      <.live_component
        module={BatchEcommerceWeb.Live.HeaderLive.HeaderBase }
        id={"header-search-#{@id}"}
        show_cart={@show_cart}
        show_search={@show_search}
        show_menu={@show_menu}
        notification_count={@notification_count}
        cart_count={@cart_count}
        user={@user}
        search_query={@search_query || ""}  # Passa vazio se não estiver definido
      />
    </div>
    """
  end
end
