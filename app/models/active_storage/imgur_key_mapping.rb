class ActiveStorage::ImgurKeyMapping < ActiveRecord::Base
  validates :key, presence: true
  validates :imgur_id, presence: true

  scope :by_prefix_key, ->(prefix) { where("key like ?", "#{prefix}%") }
end