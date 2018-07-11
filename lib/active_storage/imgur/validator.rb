module ActiveStorage
  module Imgur::Validator
    extend ActiveSupport::Concern

    included do
      alias_method :old_attach, :attach

      def attach(*attachables)
        record.public_send("invalid_#{name}=", false)
        old_attach(*attachables)
      rescue ActiveStorage::Imgur::Service::NotAnImage
        record.public_send("invalid_#{name}=", true)
      end
    end
  end
end

