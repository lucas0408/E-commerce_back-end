defmodule BatchEcommerce.Catalog.Minio do
  @behaviour BatchEcommerce.Catalog.MinioBehaviour

  @spec upload_file(map(), String.t()) :: {:ok, String.t()} | {:error, any()}
  def upload_file(upload, bucket) do
    filename = "#{UUID.uuid4()}-#{upload.filename}"
    path = upload.path

    ExAws.S3.put_object(bucket, filename, File.read!(path))
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        {:ok, get_file_url(bucket, filename)}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_file_url(String.t(), String.t()) :: String.t()
  def get_file_url(bucket, filename) do
    "http://localhost:9000/#{bucket}/#{filename}"
  end
end
