# defmodule BatchEcommerceWeb.UploadController do
#   use BatchEcommerceWeb, :controller
#   action_fallback BatchEcommerceWeb.FallbackController

#   alias BatchEcommerce.Catalog
#   alias BatchEcommerce.Catalog.{Minio, Product}

#   # TODO: implementar erro de unprocessable_entity que é retornável de upload_file no futuro
#   def create(conn, %{"image" => %Plug.Upload{} = image, "company_name" => company_name, "product_id" => product_id}) do
#     with {:ok, filename} <- Minio.upload_images(image, company_name),
#          %Product{} = _product <- Catalog.put_image_filename(product_id, filename) do
#       conn
#       |> put_status(:ok)
#       |> json(%{filename: filename})

#     else {:error, reason} ->
#       {:error, reason}
#     end
#   end
# end
