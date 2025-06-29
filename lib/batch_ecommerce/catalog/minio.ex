defmodule BatchEcommerce.Catalog.Minio do
  @behaviour BatchEcommerce.Catalog.MinioBehaviour

  @spec upload_image(Plug.Upload.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def upload_image(
        %Plug.Upload{content_type: content_type, filename: filename} = upload,
        bucket
      ) do

    new_filename = "#{UUID.uuid4()}-#{filename}"

    request =
      ExAws.S3.put_object(bucket, new_filename, upload.path, [
      {:content_type, content_type},
      {:acl, :public_read}
    ])
    |> ExAws.request()

    case request do
      {:ok, _response} -> {:ok, new_filename}
      {:error, reason} -> {:error, reason}
    end
  end

  def create_public_bucket(bucket_name) do
    create_request =
      ExAws.S3.put_bucket(bucket_name, "us-east-1")
       |> ExAws.request()

    case create_request do
      {:ok, _response} ->
        apply_public_policy(bucket_name)
        {:ok, "Bucket #{bucket_name} criado e tornado público."}

      {:error, {:http_error, 409, _}} ->
        {:error, "Bucket #{bucket_name} já existe."}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp apply_public_policy(bucket_name) do
    policy = public_policy(bucket_name)

    ExAws.S3.put_bucket_policy(bucket_name, policy)
    |> ExAws.request()
  end

  defp public_policy(bucket_name) do
    %{
      "Version" => "2012-10-17",
      "Statement" => [
        %{
          "Effect" => "Allow",
          "Principal" => "*",
          "Action" => ["s3:GetObject"],
          "Resource" => ["arn:aws:s3:::#{bucket_name}/*"]
        }
      ]
    }
    |> Jason.encode!()
  end
end
