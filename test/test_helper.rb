# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"
require 'mocha/minitest'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

SERVICE_CONFIGURATIONS = begin
  erb = ERB.new(Pathname.new(File.expand_path("service/configurations.yml", __dir__)).read)
  configuration = YAML.load(erb.result) || {}
  configuration.deep_symbolize_keys
rescue Errno::ENOENT
  puts "Missing service configuration file in test/service/configurations.yml"
  {}
end

REAL_TEST = SERVICE_CONFIGURATIONS[:imgur].present?
EMPTY_SERVICE_CONFIGURATION = { imgur: { service: 'Imgur', client_id: '', client_secret: '', refresh_token: '', access_token: '', }}

# sometime Imgurapi gem provides incorrect response message instead of what imgur given.
# enable debug mode to know what actually response content.
if ENV['DEBUG']
  class Communication < Imgurapi::Communication
    def call(method, endpoint, params = nil)
      request do
        session.connection.send(method, "/3/#{endpoint}.json", params).tap do |response|
          puts response.body
        end
      end
    end
  end
  Imgurapi::Communication = Communication
end

class ActiveSupport::TestCase
  self.fixture_path = File.expand_path("fixtures", __dir__)
  self.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"

  setup do
    ActiveStorage::Current.host = "https://example.com"
  end

  private
  def fixture_file_upload(filename)
    Rack::Test::UploadedFile.new file_fixture(filename).to_s
  end

  def gif_file
    fixture_file_upload('image.gif')
  end

  def png_file
    fixture_file_upload('image.png')
  end

  def video_file
    fixture_file_upload('video.mp4')
  end

  def random_key
    SecureRandom.base58(24)
  end

  def gif_file_data
    Base64.encode64(gif_file.read)
  end

  def random_imgur_image_data
    {
      id: SecureRandom.base58(7),
      title: nil,
      description: nil,
      datetime: Time.now.to_i,
      type: "image/gif",
      animated: false,
      width: 1,
      height: 1,
      size: 2026,
      views: 0,
      bandwidth: 0,
      vote: nil,
      favorite: false,
      nsfw: nil,
      section: nil,
      account_url: nil,
      account_id: 67555917,
      is_ad: false,
      in_most_viral: false,
      has_sound: false,
      tags: [],
      ad_type: 0,
      ad_url: "",
      in_gallery: false,
      deletehash: "oDi3InsPuJ6PiNC",
      name: "",
      link: "https://i.imgur.com/ZGWxqVE.gif",
    }
  end
end

class ActionDispatch::IntegrationTest
  self.fixture_path = File.expand_path("fixtures", __dir__)
end



