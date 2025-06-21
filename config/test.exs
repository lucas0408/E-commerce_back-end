import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :batch_ecommerce, BatchEcommerce.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "batch_ecommerce_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :batch_ecommerce, BatchEcommerceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "CltOd0XtQ+HuqaPxeMy4WC95RC0cyIN2x8Fy0UNDpjervkjnkdYTQ9CGi6bVMbRJ",
  server: false

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# In test we don't send emails.
config :batch_ecommerce, BatchEcommerce.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :ex_aws,
  access_key_id: "minioaccesskey",
  secret_access_key: "miniosecretkey",
  json_codec: Jason

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 9000,
  bucket: "batch-bucket",
  force_path_style: true
