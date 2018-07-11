Rails.application.routes.draw do
  put "/rails/active_storage/imgur/:encoded_token" => "active_storage/imgur#update", as: :update_rails_imgur_service
end
