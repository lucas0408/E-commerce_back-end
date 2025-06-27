defmodule BatchEcommerceWeb.Live.HeaderLive.HeaderFull do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.Live.HeaderLive.HeaderBase

  def render(assigns) do
    assigns =
      assigns
      |> assign(:show_cart, true)
      |> assign(:show_search, true)
      |> assign(:show_menu, false)
      |> assign_new(:notification_count, fn -> 0 end)
      |> assign_new(:cart_count, fn -> 0 end)
      |> assign_new(:user, fn -> nil end)
      |> assign_new(:search_query, fn -> "" end)

    ~H"""
    <div>
      <.live_component
        module={BatchEcommerceWeb.Live.HeaderLive.HeaderBase }
        id={"header-full-#{@id}"}
        show_cart={@show_cart}
        show_search={@show_search}
        show_menu={@show_menu}
        notification_count={@notification_count}
        cart_count={@cart_count}
        user={@user}
        search_query={@search_query}
      />
    </div>
    """
  end
end
