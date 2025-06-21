defmodule BatchEcommerceWeb.UploadController do
  use BatchEcommerceWeb, :controller
  action_fallback BatchEcommerceWeb.FallbackController

  alias BatchEcommerce.Catalog
  alias BatchEcommerce.Catalog.{Minio, Product}

  # TODO: implementar erro de unprocessable_entity que é retornável de upload_file no futuro
  def create(conn, %{"image" => %Plug.Upload{} = image, "company_name" => company_name, "product_id" => product_id}) do
    with {:ok, image_url} <- Minio.upload_image(image, company_name),
         %Product{} = _product <- Catalog.put_image_url(product_id, image_url) do
      conn
      |> put_status(:ok)
      |> json(%{image_url: image_url})

    else {:error, reason} ->
      {:error, reason}
    end
  end
end
