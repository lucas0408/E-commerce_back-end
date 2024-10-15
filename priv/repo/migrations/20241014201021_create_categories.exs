defmodule BatchEcommerce.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
