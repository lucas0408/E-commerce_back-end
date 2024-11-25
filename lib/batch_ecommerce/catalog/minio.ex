defmodule BatchEcommerce.Catalog.Minio do
  @behaviour BatchEcommerce.Catalog.MinioBehaviour

  @bucket "batch-bucket"

  @spec upload_file(Plug.Upload.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def upload_file(
        %Plug.Upload{content_type: content_type, filename: filename} = upload,
        bucket \\ @bucket
      ) do
    new_filename = "#{UUID.uuid4()}-#{filename}"

    ExAws.S3.put_object(bucket, new_filename, upload.path, [
      {:content_type, content_type},
      {:acl, :public_read}
    ])
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        {:ok, get_file_url(bucket, new_filename)}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec get_file_url(String.t(), String.t()) :: String.t()
  def get_file_url(bucket, filename) do
    "http://localhost:9000/#{bucket}/#{filename}"
  end
end
