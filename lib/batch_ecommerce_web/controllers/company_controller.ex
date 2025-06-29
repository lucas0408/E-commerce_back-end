# defmodule BatchEcommerceWeb.CompanyController do
#   use BatchEcommerceWeb, :controller

#   alias BatchEcommerce.Accounts
#   alias BatchEcommerce.Accounts.Company
#   alias BatchEcommerce.Catalog.Minio

#   action_fallback BatchEcommerceWeb.FallbackController

#   def index(conn, _params) do
#     companies = Accounts.list_companies()
#     conn
#     |> put_status(:ok)
#     |> render(:index, companies: companies)
#   end

#   def create(conn, %{"company" => company_params}) do
#     with {:ok, %Company{} = company} <- Accounts.create_company(company_params),
#     Minio.create_public_bucket(company_params.name) do
#       conn
#       |> put_status(:created)
#       |> put_resp_header("location", ~p"/api/companies/#{company}")
#       |> render(:show, company: company)
#     end
#   end

#   def show(conn, %{"id" => id}) do
#     with %Company{} = company <- Accounts.get_company(id) do
#       conn
#       |> put_status(:ok)
#       |> render(:show, company: company)
#     else
#       nil -> {:error, :not_found}
#       _unkown_error -> {:error, :internal_server_error}
#     end
#   end

#   def update(conn, %{"id" => id, "company" => company_params}) do
#     with %Company{} = company <- Accounts.get_company(id),
#     {:ok, %Company{} = company} <- Accounts.update_company(company, company_params) do
#       conn
#       |> put_status(:ok)
#       |> render(:show, company: company)
#     else
#       nil -> {:error, :not_found}
#       {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
#       _unkown_error -> {:error, :internal_server_error}
#     end
#   end

#   def delete(conn, %{"id" => id}) do
#     with %Company{} = company <- Accounts.get_company(id),
#     {:ok, %Company{}} <- Accounts.delete_company(company) do
#       send_resp(conn, :no_content, "")
#     else
#       nil -> {:error, :not_found}
#       _unkown_error -> {:error, :internal_server_error}
#     end
#   end
# end
