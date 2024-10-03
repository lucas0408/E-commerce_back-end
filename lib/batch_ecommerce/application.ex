defmodule BatchEcommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BatchEcommerceWeb.Telemetry,
      BatchEcommerce.Repo,
      {DNSCluster, query: Application.get_env(:batch_ecommerce, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BatchEcommerce.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BatchEcommerce.Finch},
      # Start a worker by calling: BatchEcommerce.Worker.start_link(arg)
      # {BatchEcommerce.Worker, arg},
      # Start to serve requests, typically the last entry
      BatchEcommerceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BatchEcommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BatchEcommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
