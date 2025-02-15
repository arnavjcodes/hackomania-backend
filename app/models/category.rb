
class Category < ApplicationRecord
  has_many :forum_threads, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 500 }
end