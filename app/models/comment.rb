class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  belongs_to :parent, class_name: "Comment", optional: true
  has_many   :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  enum mood: {
    friendly: 0,
    thoughtful: 1,
    funny: 2,
    helpful: 3,
    insightful: 4,
    excited: 5
  }, _prefix: true

  validates :content, presence: true
  # If you want to ensure *some* commentable is present:
  # validates :commentable, presence: true

  # Keep your scopes
  scope :recent, -> { order(created_at: :desc) }

  # Inherit the commentable object from the parent comment (if replying to another comment)
  before_validation :set_commentable_from_parent, if: :parent

  private

  def set_commentable_from_parent
    self.commentable ||= parent.commentable
  end
end
