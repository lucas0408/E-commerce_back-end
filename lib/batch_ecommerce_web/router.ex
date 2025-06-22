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

  #scope para usuários não logados
  scope "/", BatchEcommerceWeb do
    pipe_through :browser

    post "/login", SessionController, :create #ok
    #resources "/users", UserController, only: [:create, :show, :index] #ok
    resources "/products", ProductController, only: [:index, :show] #ok
    resources "/categories", CategoryController, only: [:index, :show] #ok
    resources "/companies", CompanyController, only: [:index, :show] #ok
  end

  #scope para usuários logados
  scope "/api", BatchEcommerceWeb do
    pipe_through [:api, :auth]

    resources "/users", UserController, only: [:update, :delete] #ok
    post "/upload", UploadController, :create #ok
    resources "/cart_products", CartProductController #ok
    #TODO: revisar action abaixo
    get "/cart_products/user/:user_id", CartProductController, :get_by_user #ok
    resources "/orders", OrderController, only: [:create, :show, :index] #ok
    post "/companies", CompanyController, :create #ok
    delete "/logout", SessionController, :logout #ok
  end

  #TODO: verificar a necessidade de criar um scope para usuários logados sem empresa e um com empresa
  #para evitar vulnerabilidades na hora de criar empresa.

  #TODO: implementar scope de api com permissão somente pra empresas
  scope "/api", BatchEcommerceWeb do
    pipe_through :browser

    resources "/products", ProductController, only: [:create, :update, :delete] #ok
    #TODO: validar se orders vai precisar de index para empresas como já definido abaixo
    #get "/orders", OrderController, :index
    resources "/companies", CompanyController, only: [:update, :delete] #ok
    #TODO: revisar action abaixo
    get "/orders/export-stream", OrderController, :export_stream #ok

  end

  scope "/", BatchEcommerceWeb.Live do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{BatchEcommerceWeb.UserAuth, :ensure_authenticated}] do
      live "/users", UserLive.Index, :index
      live "/users/:id/edit", UserLive.Edit, :edit
      live "/products/new", ProductLive.New, :new
      live "/products/:product_id", ProductLive.Show, :edit
      live "/products/:product_id/edit", ProductLive.Edit, :edit
      live "/companies/new", CompanyLive.New, :new
      live "/companies/:id/edit", CompanyLive.Edit, :edit
      live "/companies/:company_id/products", CompanyLive.ProductIndex, :product_index
      live "/companies/:company_id/orders", CompanyLive.OrderIndex, :order_index
      live "/companies/:id/orders", OrderLive.Index, :index
      live "/cart_products", ShoppingCart.Index, :index
      live "/orders", OrderLive.Index, :index
    end

    live "/companies/:id", CompanyLive.Show, :show
    #live "/users/:id", UserLive.Show, :show
    live "/products", ProductLive.Index, :index
  end

  scope "/", BatchEcommerceWeb do
    pipe_through [:browser]

    live "/users/log_in", UserLoginLive, :new
    live "/users/new", UserLive.New, :new
    live "/users/register", UserRegistrationLive, :new
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
