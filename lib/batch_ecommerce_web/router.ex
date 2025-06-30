defmodule BatchEcommerceWeb.Router do
  use BatchEcommerceWeb, :router

  import BatchEcommerceWeb.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BatchEcommerce.Accounts.Pipeline
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BatchEcommerceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  #scope para usuários não logados tem que migrar pro liveview
  scope "/", BatchEcommerceWeb do
    pipe_through :browser

    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
    get "/orders/export-stream", OrderController, :export_stream
  end

  scope "/", BatchEcommerceWeb do
    pipe_through :browser

    live_session :redirect_if_user_is_authenticated,
    on_mount: [{BatchEcommerceWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/login", UserLoginLive, :new
      live "/register", UserLive.New, :new
    end

    live "/sobre", Live.AboutLive
    live "/products", Live.ProductLive.Index, :index
    live "/users/:id", Live.UserLive.Show, :show
  end

  #scope de usuarios logados com o liveview
  scope "/", BatchEcommerceWeb.Live do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BatchEcommerceWeb.UserAuth, :ensure_authenticated}] do
      live "/users", UserLive.Index, :index
      live "/users/:id/edit", UserLive.Edit, :edit
      live "/products/:product_id", ProductLive.Show, :edit
      live "/companies/new", CompanyLive.New, :new
      live "/address/new", AddressLive.Form, :new
      live "/cart_products", ShoppingCart.Index, :index
      live "/orders", OrderLive.Index, :index
      live "/orders/:order_id", OrderLive.ShowUser, :show
    end
  end

  #scope de usuário logado e com empresa
  scope "/", BatchEcommerceWeb.Live do
    pipe_through [:browser]

    live_session :require_authenticated_and_has_company,
      on_mount: {BatchEcommerceWeb.UserAuth, :require_authenticated_and_has_company} do
      live "/companies", CompanyLive.Show, :show
      live "/companies/:id/edit", CompanyLive.Edit, :edit
      live "/companies/:company_id/products", CompanyLive.ProductIndex, :product_index
      live "/companies/:company_id/orders", CompanyLive.OrderIndex, :order_index
      live "/companies/:company_id/orders/:order_id", OrderLive.ShowCompany, :order_index
      live "/products/new", ProductLive.New, :new
      live "/products/:product_id/edit", ProductLive.Edit, :edit
      #live "/companies/:id/orders", OrderLive.Index, :index REVIEW: rota duplicada
    end
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :batch_ecommerce, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "BatchEcommerce"
      }
    }
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:batch_ecommerce, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BatchEcommerceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
