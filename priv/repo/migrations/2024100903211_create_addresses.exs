defmodule BatchEcommerce.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :cep, :string
      add :uf, :string
      add :city, :string
      add :district, :string
      add :address, :string
      add :complement, :string
      add :home_number, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
