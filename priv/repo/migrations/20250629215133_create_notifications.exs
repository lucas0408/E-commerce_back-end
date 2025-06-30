defmodule BatchEcommerce.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :title, :string
      add :body, :text
      add :viewed, :boolean, default: false

      add :recipient_user_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :recipient_company_id, references(:companies, on_delete: :nilify_all)

      timestamps()
    end

    create index(:notifications, [:recipient_user_id])
    create index(:notifications, [:recipient_company_id])
  end
end
