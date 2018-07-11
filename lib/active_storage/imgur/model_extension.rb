module ActiveStorage
  module Imgur::ModelExtension
    extend ActiveSupport::Concern

    class_methods do
      def has_one_attached(*arg)
        super(*arg)
        name = arg.first
        validate_image(name)
      end

      def has_many_attached(*arg)
        super(*arg)
        name = arg.first
        validate_image(name)
      end

      private
      def validate_image(name)
        validate "validate_imgur_#{name}".to_sym

        generated_association_methods.class_eval <<-CODE
          attr_accessor :invalid_#{name}

          def validate_imgur_#{name}
            if invalid_#{name}
              errors.add(:#{name}, "is not an image")
            end
          end
        CODE
      end
    end
  end
end

