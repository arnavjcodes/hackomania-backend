

class Tag < ApplicationRecord
  has_and_belongs_to_many :forum_threads

  has_many :resource_tags, dependent: :destroy
  has_many :resources, through: :resource_tags

  validates :name, presence: true, uniqueness: true
end
