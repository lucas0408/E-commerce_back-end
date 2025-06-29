defmodule BatchEcommerce.Catalog.MinioBehaviour do
  @callback upload_image(Phoenix.LiveView.Socket.t(), any()) ::
  {:error, <<_::64, _::_*8>>} | {:ok, list()}
end
