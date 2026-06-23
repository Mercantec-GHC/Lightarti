class Folder < ApplicationRecord
  validates :name, presence: true
  has_many :artifacts, dependent: :destroy
  has_many :folder_permissions, dependent: :destroy
  has_many :users, through: :folder_permissions
  belongs_to :parent,
            class_name: "Folder",
            optional: true

  has_many :children,
           class_name: "Folder",
           foreign_key: :parent_id,
           dependent: :destroy

  validates :name,
          presence: true,
          uniqueness: { scope: :parent_id }
end
