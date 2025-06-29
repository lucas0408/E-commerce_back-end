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

    post "/login", SessionController, :create #nao migrar
    delete "/logout", SessionController, :delete
    #resources "/users", UserController, only: [:create, :show, :index] ---- migrado
    #resources "/products", ProductController, only: [:index, :show] ---- migrado
    resources "/categories", CategoryController, only: [:index, :show] #ok
    #resources "/companies", CompanyController, only: [:index, :show] #ok
  end

  #scope para usuários logados tem que migrar pro liveview
  scope "/api", BatchEcommerceWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, only: [:update, :delete] 
    post "/upload", UploadController, :create 
    resources "/cart_products", CartProductController 
    #TODO: revisar action abaixo
    get "/cart_products/user/:user_id", CartProductController, :get_by_user 
    resources "/orders", OrderController, only: [:create, :show, :index] 
    post "/companies", CompanyController, :create
  end

  scope "/", BatchEcommerceWeb do
    pipe_through [:browser]

    live "/login", UserLoginLive, :new
    live "/products", Live.ProductLive.Index, :index
    live "/register", UserLive.New, :new
  end

  #scope de usuarios logados com o liveview
  scope "/", BatchEcommerceWeb.Live do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BatchEcommerceWeb.UserAuth, :ensure_authenticated}] do
      live "/users", UserLive.Index, :index
      live "/users/:id/edit", UserLive.Edit, :edit
      live "/products", ProductLive.Index, :index
      live "/products/new", ProductLive.New, :new
      live "/products/:product_id", ProductLive.Show, :edit
      live "/products/:product_id/edit", ProductLive.Edit, :edit
      live "/users/:id", UserLive.Show, :show
      live "/companies/new", CompanyLive.New, :new
      live "/address/new", AddressLive.Form, :new
      live "/cart_products", ShoppingCart.Index, :index
      live "/orders", OrderLive.Index, :index
      live "/orders/:order_id", OrderLive.ShowUser, :show
    end
  end

  #scope de usuário logado e com empresa
  scope "/companies", BatchEcommerceWeb.Live do
    pipe_through [:browser]

    live_session :require_authenticated_and_has_company,
      on_mount: {BatchEcommerceWeb.UserAuth, :require_authenticated_and_has_company} do
      live "/", CompanyLive.Show, :show
      live "/:id/edit", CompanyLive.Edit, :edit
      live "/:company_id/products", CompanyLive.ProductIndex, :product_index
      live "/:company_id/orders", CompanyLive.OrderIndex, :order_index
      live "/:company_id/orders/:order_id", OrderLive.ShowCompany, :order_index
      #live "/companies/:id/orders", OrderLive.Index, :index REVIEW: rota duplicada
    end
  end

  #scope de api que tem que ser migrado
  scope "/api", BatchEcommerceWeb do
    pipe_through [:api, :auth, :ensure_auth]
    post "/upload", UploadController, :create
    resources "/users", UserController, except: [:create, :show, :new, :edit]
    #resources "/products", ProductController, except: [:index, :show, :new, :edit]
    resources "/categories", CategoryController, except: [:new, :index, :edit]
    resources "/cart_products", CartProductController
    get "/cart_products/user/:user_id", CartProductController, :get_by_user
    resources "/orders", OrderController, only: [:create, :show, :index]
    get "/orders/export-stream", OrderController, :export_stream
    resources "/companies", CompanyController
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