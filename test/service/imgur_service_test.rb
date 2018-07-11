class ActiveStorage::Service::ImgurServiceTest < ActiveSupport::TestCase
  SERVICE = ActiveStorage::Service.configure(
    :imgur, REAL_TEST ? SERVICE_CONFIGURATIONS : EMPTY_SERVICE_CONFIGURATION)

  attr_reader :key, :service

  setup do
    @key = random_key
    @service = self.class.const_get(:SERVICE)

    unless REAL_TEST
      Imgurapi::Api::Image.any_instance.stubs(:image_upload).returns(Imgurapi::Image.new(random_imgur_image_data))
      Imgurapi::Api::Image.any_instance.stubs(:image_delete).returns(true)
    end
  end

  teardown do
    service.delete key
  end

  test "uploading without integrity" do
    assert_raises(ActiveStorage::IntegrityError) do
      service.upload(key, gif_file, checksum: Digest::MD5.base64digest("bad data"))
    end
    assert_not service.exist?(key)
  end

  test "uploading image file with integrity" do
    service.upload(key, gif_file, checksum: Digest::MD5.file(gif_file).base64digest)
    assert service.exist?(key)
  end

  test "uploading an image file" do
    service.upload(key, gif_file)
    assert service.exist?(key)
  end

  test "existing" do
    assert_not service.exist?(key)
    service.upload(key, gif_file)
    assert service.exist?(key)
  end

  test "deleting" do
    service.upload(key, gif_file)
    assert_nothing_raised do
      service.delete(random_key)
    end
    service.delete(key)
    assert_not service.exist?(key)
  end

  test "deleting by prefix" do
    service.upload("a/a/a", gif_file)
    service.upload("a/a/b", gif_file)
    service.upload("a/b/a", gif_file)

    service.delete_prefixed("a/a/")
    assert_not service.exist?("a/a/a")
    assert_not service.exist?("a/a/b")
    assert service.exist?("a/b/a")
  end
end