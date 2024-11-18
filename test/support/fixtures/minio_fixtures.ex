defmodule BatchEcommerce.MinioFixtures do
  def upload_fixture do
    %Plug.Upload{
      content_type: "image/jpeg",
      filename: "test.jpg",
      path: create_temp_file()
    }
  end

  defp create_temp_file do
    path = Path.join(System.tmp_dir!(), "test_#{:rand.uniform(1000)}.jpg")
    File.write!(path, "fake image content")
    path
  end
end
