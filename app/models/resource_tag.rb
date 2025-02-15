class ResourceTag < ApplicationRecord
  belongs_to :resource
  belongs_to :tag

  validates :resource_id, uniqueness: { scope: :tag_id }
end
