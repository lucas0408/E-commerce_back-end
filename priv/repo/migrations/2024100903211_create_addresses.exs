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

      timestamps(type: :utc_datetime)
    end
  end
end
