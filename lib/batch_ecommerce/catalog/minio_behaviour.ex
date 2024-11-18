defmodule BatchEcommerce.Catalog.MinioBehaviour do
  @callback upload_file(Plug.Upload.t(), String.t()) :: {:ok, String.t()} | {:error, any()}
  @callback get_file_url(String.t(), String.t()) :: String.t()
end
