class Artifact < ApplicationRecord
  belongs_to :folder
  belongs_to :user
  validates :name, presence: true
  validates :storage_key, presence: true
end
