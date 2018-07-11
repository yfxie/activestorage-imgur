require 'active_support/lazy_load_hooks'

module ActiveStorage
  module Imgur
    class Engine < ::Rails::Engine
      isolate_namespace ActiveStorage::Imgur

      initializer 'include imgur validator' do
        ActiveStorage::Attached::One.include ActiveStorage::Imgur::Validator
        ActiveStorage::Attached::Many.include ActiveStorage::Imgur::Validator
      end

      initializer 'include model extension' do
        ActiveRecord::Base.include ActiveStorage::Imgur::ModelExtension
      end

      initializer 'enhance Imgur::Communication' do
        ::Imgurapi::Communication
      end

      rake_tasks do
        load 'imgurapi/tasks/tasks.rake'
      end
    end
  end
end

