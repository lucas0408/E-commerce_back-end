defmodule BatchEcommerceWeb.UploadControllerTest do
  use BatchEcommerceWeb.ConnCase, async: true

  import BatchEcommerce.AccountsFixtures
  import BatchEcommerce.CatalogFixtures
  alias BatchEcommerce.Accounts.Guardian

  import Hammox

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "upload_image/1" do
    setup [:create_session, :create_image, :create_product]

    test "successfully uploads an image", %{conn: conn, upload: upload, product_id: product_id} do
      expect(BatchEcommerce.Catalog.MockMinio, :upload_file, fn ^upload, "test-bucket" ->
        {:ok, "http://localhost:9000/test-bucket/test.jpg"}
      end)

      # use by_pass server in the future to test
      conn = post(conn, ~p"/api/upload", %{image: upload, product_id: product_id})
      response = json_response(conn, 200)

      assert String.match?(
               response["image_url"],
               ~r|http://localhost:9000/batch-bucket/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-test_image\.jpg|
             )
    end
  end

  defp create_image(_) do
    tmp_path = Path.join(System.tmp_dir!(), "test.jpg")
    File.write!(tmp_path, "test-content")

    upload = %Plug.Upload{
      path: tmp_path,
      filename: "test_image.jpg",
      content_type: "image/jpeg"
    }

    on_exit(fn ->
      File.rm(tmp_path)
    end)

    {:ok, %{upload: upload}}
  end

  defp create_session(%{conn: conn}) do
    user = user_fixture()
    conn = Guardian.Plug.sign_in(conn, user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    %{conn: put_req_header(conn, "authorization", "Bearer #{token}"), user: user}
  end

  defp create_product(_) do
    product = product_fixture()
    %{product_id: product.id}
  end
end
