ExUnit.start()
{:ok, _} = Application.ensure_all_started(:ex_machina)
Ecto.Adapters.SQL.Sandbox.mode(BatchEcommerce.Repo, :manual)
Mox.defmock(BatchEcommerce.Catalog.MockMinio, for: BatchEcommerce.Catalog.MinioBehaviour)
