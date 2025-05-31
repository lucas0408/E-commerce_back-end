defmodule BatchEcommerceWeb.Router do
  use BatchEcommerceWeb, :router

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
    plug :fetch_current_user
    plug :put_secure_browser_headers
  end

  defp fetch_current_user(conn, _opts) do
    # Para desenvolvimento - pega o primeiro usuário
    # Em produção, você deve pegar da sessão ou token de autenticação
    IO.inspect(BatchEcommerce.Accounts.list_companies())
    current_user = List.first(BatchEcommerce.Accounts.list_users())
    company = BatchEcommerce.Accounts.get_company_by_user_id(current_user.id)

    
    conn
    |> assign(:current_user, current_user)
    |> put_session(:current_user, current_user)
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", BatchEcommerceWeb do
    pipe_through [:api, :auth]

    
    resources "/users", UserController, only: [:create, :show]
    resources "/products", ProductController, only: [:index, :show]
    resources "/categories", CategoryController, only: [:index]
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
    get "/orders/export-stream", OrderController, :export_stream
  end

  scope "/", BatchEcommerceWeb.Live do
    pipe_through :browser

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.New, :new
    live "/users/:id/edit", UserLive.Edit, :edit
    live "/products/new", ProductLive.New, :new
    live "/products/:product_id/edit", ProductLive.Edit, :edit
    live "/users/:id", UserLive.Show, :show
    live "/companies/new", CompanyLive.New, :new
    live "/companies/:id", CompanyLive.Show, :show
    live "/companies/:id/edit", CompanyLive.Edit, :edit
    live "/companies/:company_id/products", CompanyLive.ProductIndex, :product_index
    live "/companies/:company_id/orders", CompanyLive.OrderIndex, :order_index
    live "/companies/:id/orders", OrderLive.Index, :index

    get "/", PageController, :home
  end

  scope "/api", BatchEcommerceWeb do
    pipe_through [:api, :auth, :ensure_auth]
    post "/upload", UploadController, :create
    resources "/users", UserController, except: [:create, :show, :new, :edit]
    resources "/products", ProductController, except: [:index, :show, :new, :edit]
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
