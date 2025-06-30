defmodule BatchEcommerce.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :cnpj, :string, null: false
      add :user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone_number, :string, null: false
      add :profile_filename, :string
      add :minio_bucket_name, :string

      timestamps()
    end

    # Índices para otimização de busca e garantia de unicidade
    create unique_index(:companies, [:cnpj], name: :companies_cnpj_index)
    create unique_index(:companies, [:name], name: :companies_name_index)
    create unique_index(:companies, [:email], name: :companies_email_index)
    create unique_index(:companies, [:phone_number], name: :companies_phone_number_index)
    create index(:companies, [:user_id])
  end
end
