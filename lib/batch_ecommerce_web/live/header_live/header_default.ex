defmodule BatchEcommerceWeb.Live.HeaderLive.HeaderDefault do
  use BatchEcommerceWeb, :live_component
  import BatchEcommerceWeb.Live.HeaderLive.HeaderHelpers

  def render(assigns) do
    assigns =
      assigns
      |> assign_new(:notification_count, fn -> 0 end)
      |> assign_new(:cart_count, fn -> 0 end)
      |> assign_new(:user, fn -> nil end)
      |> assign_new(:search_query, fn -> "" end)

    ~H"""
    <div>
      <.live_component 
        module={BatchEcommerceWeb.Live.HeaderLive.HeaderHelpers} 
        id={"header-default-#{@id}"}
        show_cart={false}
        show_search={false}
        show_menu={false}
        notification_count={@notification_count}
        cart_count={@cart_count}
        user={@user}
        search_query={@search_query}
      />
    </div>
    """
  end
end
