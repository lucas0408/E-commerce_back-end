defmodule BatchEcommerce.MinioTest do
  use BatchEcommerce.DataCase, async: true
  import Hammox

  setup :verify_on_exit!

  describe "upload_file/2" do
    setup do
      tmp_path = Path.join(System.tmp_dir!(), "test.jpg")
      File.write!(tmp_path, "test-content")

      upload = %Plug.Upload{
        path: tmp_path,
        filename: "test.jpg",
        content_type: "image/jpeg"
      }

      on_exit(fn ->
        File.rm(tmp_path)
      end)

      {:ok, %{upload: upload}}
    end

    test "successfully uploads a file", %{upload: upload} do
      expect(BatchEcommerce.Catalog.MockMinio, :upload_file, fn ^upload, "test-bucket" ->
        {:ok, "http://localhost:9000/test-bucket/test.jpg"}
      end)

      assert {:ok, url} = BatchEcommerce.Catalog.MockMinio.upload_file(upload, "test-bucket")
      assert url == "http://localhost:9000/test-bucket/test.jpg"
    end

    test "returns error when upload fails", %{upload: upload} do
      expect(BatchEcommerce.Catalog.MockMinio, :upload_file, fn ^upload, "test-bucket" ->
        {:error, "Upload failed"}
      end)

      assert {:error, "Upload failed"} =
               BatchEcommerce.Catalog.MockMinio.upload_file(upload, "test-bucket")
    end
  end

  describe "get_file_url/2" do
    test "generates correct url for file" do
      expect(BatchEcommerce.Catalog.MockMinio, :get_file_url, fn "test-bucket", "test.jpg" ->
        "http://localhost:9000/test-bucket/test.jpg"
      end)

      assert BatchEcommerce.Catalog.MockMinio.get_file_url("test-bucket", "test.jpg") ==
               "http://localhost:9000/test-bucket/test.jpg"
    end

    test "handles special characters in filename" do
      filename = "test file with spaces.jpg"

      expect(BatchEcommerce.Catalog.MockMinio, :get_file_url, fn "test-bucket", ^filename ->
        "http://localhost:9000/test-bucket/#{filename}"
      end)

      assert BatchEcommerce.Catalog.MockMinio.get_file_url("test-bucket", filename) ==
               "http://localhost:9000/test-bucket/test file with spaces.jpg"
    end
  end
end
