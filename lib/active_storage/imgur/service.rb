require 'open-uri'
require 'down'

module ActiveStorage
  module Imgur
    class Service < ActiveStorage::Service
      class NotAnImage < StandardError; end

      attr_reader :client

      def initialize(client_id:, client_secret:, refresh_token:, access_token:)
        @client = ::Imgurapi::Session.instance(
          client_id: client_id, client_secret: client_secret,
          refresh_token: refresh_token, access_token: access_token)
      end

      # Upload the +io+ to the +key+ specified. If a +checksum+ is provided, the service will
      # ensure a match when the upload has completed or raise an ActiveStorage::IntegrityError.
      def upload(key, io, checksum: nil, **)
        instrument :upload, key: key, checksum: checksum do
          if io.is_a?(StringIO)
            io = string_io_to_file(key, io)
          end

          ensure_integrity_of(key, io, checksum) if checksum
          image = client.image.image_upload(io)

          ActiveStorage::ImgurKeyMapping.create(key: key, imgur_id: image.id)
        end
      rescue StandardError => e
        if e.message.match(/must be an image/)
          raise NotAnImage
        else
          raise e
        end
      end

      # Return the content of the file at the +key+.
      def download(key, &block)
        if block_given?
          instrument :streaming_download, key: key do
            stream(key, &block)
          end
        else
          instrument :download, key: key do
            File.binread file_for(key)
          end
        end
      end

      # Return the partial content in the byte +range+ of the file at the +key+.
      def download_chunk(key, range)
        instrument :download_chunk, key: key, range: range do
          file = file_for(key)
          file.seek range.begin
          file.read range.size
        end
      end

      # Delete the file at the +key+.
      def delete(key)
        instrument :delete, key: key do
          map = find_map_by_key(key)
          if map
            client.image.image_delete(map.imgur_id)
            map.destroy!
          end
        end
      end

      # Delete files at keys starting with the +prefix+.
      def delete_prefixed(prefix)
        instrument :delete_prefixed, prefix: prefix do
          maps = ActiveStorage::ImgurKeyMapping.by_prefix_key(prefix)
          maps.each do |map|
            client.image.image_delete(map.imgur_id)
            map.destroy!
          end
        end
      end

      # Return +true+ if a file exists at the +key+.
      def exist?(key)
        instrument :exist, key: key do |payload|
          id = map_key_to_id(key)
          answer = id.present?

          payload[:exist] = answer
          answer
        end
      end

      # Returns a signed, temporary URL for the file at the +key+. The URL will be valid for the amount
      # of seconds specified in +expires_in+. You must also provide the +disposition+ (+:inline+ or +:attachment+),
      # +filename+, and +content_type+ that you wish the file to be served with on request.
      def url(key, expires_in:, disposition:, filename:, content_type:)
        instrument :url, key: key do |payload|
          image = image_for(key)

          image.link.tap do |url|
            payload[:url] = url
          end
        end
      end

      # Returns a signed, temporary URL that a direct upload file can be PUT to on the +key+.
      # The URL will be valid for the amount of seconds specified in +expires_in+.
      # You must also provide the +content_type+, +content_length+, and +checksum+ of the file
      # that will be uploaded. All these attributes will be validated by the service upon upload.
      def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
        instrument :url, key: key do |payload|
          verified_token_with_expiration = ActiveStorage.verifier.generate(
            {
              key: key,
              content_type: content_type,
              content_length: content_length,
              checksum: checksum
            },
            { expires_in: expires_in,
              purpose: :blob_token }
          )

          generated_url = url_helpers.update_rails_imgur_service_url(verified_token_with_expiration, host: current_host)

          payload[:url] = generated_url
          generated_url
        end
      end

      def headers_for_direct_upload(key, content_type:, checksum:, **)
        { "Content-Type" => content_type, "Content-MD5" => checksum }
      end

      private
      def ensure_integrity_of(key, file, checksum)
        unless Digest::MD5.file(file).base64digest == checksum
          delete key
          raise ActiveStorage::IntegrityError
        end
      end

      def find_map_by_key(key)
        ActiveStorage::ImgurKeyMapping.find_by(key: key)
      end

      def map_key_to_id(key)
        map = find_map_by_key(key)
        if map
          map.imgur_id
        end
      end

      def image_for(key)
        id = map_key_to_id(key)
        client.image.image(id)
      end

      def file_for(key)
        image = image_for(key)
        Down.download(image.link)
      end

      def string_io_to_file(key, string_io)
        ext = File.extname(key)
        base = File.basename(key, ext)
        Tempfile.new([base, ext]).tap do |file|
          file.write string_io
        end
      end

      def stream(key)
        image = image_for(key)
        remote_file = Down.open(image.link)

        chunk_size = 128.kilobytes


        while !remote_file.eof?
          yield remote_file.read(chunk_size)
        end
      end

      def url_helpers
        @url_helpers ||= Rails.application.routes.url_helpers
      end

      def current_host
        ActiveStorage::Current.host
      end
    end
  end

end