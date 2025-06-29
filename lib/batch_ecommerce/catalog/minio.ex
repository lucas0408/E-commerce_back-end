defmodule BatchEcommerce.Catalog.Minio do
  #@behaviour BatchEcommerce.Catalog.MinioBehaviour


  def upload_images(socket, bucket, upload_name \\ :image) do

    uploaded_files =
      Phoenix.LiveView.consume_uploaded_entries(socket, upload_name, fn %{path: path}, entry ->
        new_filename = "#{UUID.uuid4()}-#{entry.client_name}"

        case ExAws.S3.put_object(bucket, new_filename, File.read!(path), [
          {:content_type, entry.client_type},
          {:acl, :public_read}
        ]) |> ExAws.request() do
          {:ok, _msg} -> {:ok, new_filename}
          {:error, reason} -> {:error, reason}
        end
      end)

    filename_with_host = build_preview_url(bucket, uploaded_files)
    errors = Enum.filter(uploaded_files, &match?({:error, _}, &1))

    case errors do
      [] ->
        {:ok, filename_with_host}
      _ ->
        {:error, "Upload failed: #{inspect(errors)}"}
    end
  end

  defp build_preview_url(bucket, filename) do
    base_url = get_base_url()  # You'll need to implement this
    "#{base_url}/api/v1/buckets/#{bucket}/objects/download?preview=true&prefix=#{filename}&version_id=null"
  end

  # You can get the base URL from config or environment
  defp get_base_url() do
    "http://localhost:9001"
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
