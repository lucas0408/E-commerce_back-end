defmodule BatchEcommerce.Accounts.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "notifications" do
    field :title, :string
    field :body, :string
    field :viewed, :boolean, default: false

    belongs_to :recipient_user, BatchEcommerce.Accounts.User, type: :binary_id
    belongs_to :recipient_company, BatchEcommerce.Companies.Company

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [
      :title, :body, :viewed,
      :recipient_user_id, :recipient_company_id
    ])
    |> validate_required([:title, :body])
    |> validate_at_least_one(:recipient_user_id, :recipient_company_id)
  end

  # Validação customizada: exige pelo menos um dos dois campos
  defp validate_at_least_one(changeset, field1, field2) do
    if get_field(changeset, field1) || get_field(changeset, field2) do
      changeset
    else
      add_error(changeset, field1, "deve ser informado pelo menos um dos dois campos (#{field1} ou #{field2})")
    end
  end
end
