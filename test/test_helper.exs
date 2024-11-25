ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(BatchEcommerce.Repo, :manual)
Mox.defmock(BatchEcommerce.Catalog.MockMinio, for: BatchEcommerce.Catalog.MinioBehaviour)
