

class Tag < ApplicationRecord
  has_and_belongs_to_many :forum_threads

  validates :name, presence: true, uniqueness: true
end
