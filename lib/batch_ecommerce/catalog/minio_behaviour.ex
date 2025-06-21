defmodule BatchEcommerce.Catalog.MinioBehaviour do
  @callback upload_image(Plug.Upload.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
end
