class Resource < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :resource_tags, dependent: :destroy
  has_many :tags, through: :resource_tags
  has_many :resource_comments, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :resource_type, presence: true
  validate :content_or_url_present

  # Scopes for filtering
  scope :published, -> { where(published: true) }
  scope :approved, -> { where(approved: true) }
  scope :by_type, ->(rtype) { where(resource_type: rtype) if rtype.present? }
  scope :with_tag, ->(tag_name) {
    joins(:tags).where(tags: { name: tag_name }) if tag_name.present?
  }
  scope :search, ->(query) {
    where("title ILIKE :q OR description ILIKE :q OR content ILIKE :q", q: "%#{query}%") if query.present?
  }
  scope :ordered_by_rating, -> { order(rating: :desc) }
  scope :ordered_by_views, -> { order(view_count: :desc) }

  # Methods to increment views and adjust rating
  def increment_view!
    increment!(:view_count)
  end

  def upvote!
    # Increase the rating by 1 (for a more detailed system, you’d track per-user votes)
    update(rating: rating.to_f + 1)
  end

  def downvote!
    update(rating: rating.to_f - 1)
  end

  private

  def content_or_url_present
    if content.blank? && url.blank?
      errors.add(:base, "Either content or URL must be provided.")
    end
  end
end
